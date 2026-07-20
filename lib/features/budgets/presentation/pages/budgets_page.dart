import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/category_x.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Бюджеты')),
    floatingActionButton: FloatingActionButton.extended(
      heroTag: 'budgets_fab',
      onPressed: () => _openForm(context),
      icon: const Icon(Icons.add),
      label: const Text('Бюджет'),
    ),
    body: BlocBuilder<BudgetsBloc, BudgetsState>(
      builder: (context, state) => switch (state.status) {
        BudgetsStatus.initial || BudgetsStatus.loading => const LoadingView(),
        BudgetsStatus.failure => ErrorState(
          message: state.failure?.message ?? 'Попробуйте ещё раз',
          onRetry: () =>
              context.read<BudgetsBloc>().add(const BudgetsRequested()),
        ),
        BudgetsStatus.empty => EmptyState(
          title: 'Бюджеты не заданы',
          message: 'Установите лимит для категории и следите за прогрессом.',
          action: FilledButton(
            onPressed: () => _openForm(context),
            child: const Text('Создать бюджет'),
          ),
        ),
        BudgetsStatus.success => RefreshIndicator(
          onRefresh: () async {
            context.read<BudgetsBloc>().add(
              const BudgetsRequested(refresh: true),
            );
            await context.read<BudgetsBloc>().stream.firstWhere(
              (value) => value.status != BudgetsStatus.loading,
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: state.budgets.length,
            itemBuilder: (context, index) =>
                _BudgetCard(budget: state.budgets[index]),
          ),
        ),
      },
    ),
  );
}

Future<void> _openForm(BuildContext context, [Budget? budget]) async {
  final result = await showModalBottomSheet<Budget>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _BudgetForm(budget: budget),
  );
  if (result != null && context.mounted) {
    context.read<BudgetsBloc>().add(BudgetSaved(result));
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget});
  final Budget budget;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = budget.isExceeded
        ? scheme.error
        : budget.isWarning
        ? Colors.orange
        : scheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: budget.categoryId.color.withValues(
                    alpha: .15,
                  ),
                  child: Icon(
                    budget.categoryId.icon,
                    color: budget.categoryId.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.categoryId.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${formatMoney(budget.spent)} из ${formatMoney(budget.limit)}',
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') await _openForm(context, budget);
                    if (value == 'delete' &&
                        context.mounted &&
                        await showConfirmation(
                          context,
                          title: 'Удалить бюджет?',
                          message:
                              'Лимит для категории «${budget.categoryId.label}» будет удалён.',
                        )) {
                      if (context.mounted) {
                        context.read<BudgetsBloc>().add(
                          BudgetDeleted(budget.id),
                        );
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                    PopupMenuItem(value: 'delete', child: Text('Удалить')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: budget.progress.clamp(0, 1),
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              budget.isExceeded
                  ? 'Лимит превышен на ${formatMoney(budget.spent - budget.limit)}'
                  : budget.isWarning
                  ? 'Использовано более 80% бюджета'
                  : 'Осталось ${formatMoney(budget.limit - budget.spent)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetForm extends StatefulWidget {
  const _BudgetForm({this.budget});
  final Budget? budget;
  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController limit;
  late AppCategory category;
  @override
  void initState() {
    super.initState();
    limit = TextEditingController(
      text: widget.budget?.limit.toStringAsFixed(0) ?? '',
    );
    category = widget.budget?.categoryId ?? AppCategory.groceries;
  }

  @override
  void dispose() {
    limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.budget == null ? 'Новый бюджет' : 'Редактирование бюджета',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppCategory>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Категория'),
              items: AppCategory.values
                  .where((value) => value != AppCategory.salary)
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => category = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: limit,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Месячный лимит',
                prefixIcon: Icon(Icons.currency_ruble),
              ),
              validator: (value) {
                final number = double.tryParse(
                  (value ?? '').replaceAll(',', '.'),
                );
                return number == null || number <= 0
                    ? 'Введите положительный лимит'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (!(key.currentState?.validate() ?? false)) return;
                final now = DateTime.now();
                Navigator.pop(
                  context,
                  Budget(
                    id:
                        widget.budget?.id ??
                        'budget-${now.microsecondsSinceEpoch}',
                    categoryId: category,
                    limit: double.parse(limit.text.replaceAll(',', '.')),
                    month: widget.budget?.month ?? now.month,
                    year: widget.budget?.year ?? now.year,
                  ),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    ),
  );
}
