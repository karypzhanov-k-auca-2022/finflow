import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/category_use_cases.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';

Category _resolveCategory(String categoryId, List<Category> categories) {
  return categories.firstWhere(
    (c) => c.id == categoryId,
    orElse: () => Category(
      id: categoryId,
      name: categoryId,
      iconCodePoint: 0xe59a,
      colorValue: 0xFF9E9E9E,
    ),
  );
}

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  List<Category> availableCategories = defaultCategoryModels;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final res = await getIt<CategoryUseCases>().load();
    if (res is Success<List<Category>> && mounted) {
      setState(() {
        availableCategories = res.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Бюджеты')),
    floatingActionButton: FloatingActionButton.extended(
      heroTag: 'budgets_fab',
      onPressed: () => _openForm(context, null, availableCategories),
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
            onPressed: () => _openForm(context, null, availableCategories),
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
            itemBuilder: (context, index) => _BudgetCard(
              budget: state.budgets[index],
              categories: availableCategories,
            ),
          ),
        ),
      },
    ),
  );

  Future<void> _openForm(
    BuildContext context,
    Budget? budget,
    List<Category> categories,
  ) async {
    final result = await showModalBottomSheet<Budget>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BudgetForm(budget: budget, categories: categories),
    );
    if (result != null && context.mounted) {
      context.read<BudgetsBloc>().add(BudgetSaved(result));
    }
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.categories});
  final Budget budget;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final cat = _resolveCategory(budget.categoryId, categories);
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
                  backgroundColor: cat.color.withValues(alpha: .15),
                  child: Icon(
                    cat.icon,
                    color: cat.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
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
                    if (value == 'edit') {
                      final result = await showModalBottomSheet<Budget>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => _BudgetForm(
                          budget: budget,
                          categories: categories,
                        ),
                      );
                      if (result != null && context.mounted) {
                        context.read<BudgetsBloc>().add(BudgetSaved(result));
                      }
                    }
                    if (value == 'delete' &&
                        context.mounted &&
                        await showConfirmation(
                          context,
                          title: 'Удалить бюджет?',
                          message:
                              'Лимит для категории «${cat.name}» будет удалён.',
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
  const _BudgetForm({this.budget, required this.categories});
  final Budget? budget;
  final List<Category> categories;

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController limit;
  late String categoryId;

  @override
  void initState() {
    super.initState();
    limit = TextEditingController(
      text: widget.budget?.limit.toStringAsFixed(0) ?? '',
    );
    categoryId = widget.budget?.categoryId ??
        (widget.categories.any((c) => c.id != 'salary')
            ? widget.categories.firstWhere((c) => c.id != 'salary').id
            : widget.categories.first.id);
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
            DropdownButtonFormField<String>(
              initialValue: categoryId,
              decoration: const InputDecoration(labelText: 'Категория'),
              items: widget.categories
                  .where((c) => c.id != 'salary')
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => categoryId = value!),
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
                    categoryId: categoryId,
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
