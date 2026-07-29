import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/extensions/l10n_x.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/category_x.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/category_use_cases.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/budget_use_cases.dart';
import '../bloc/budgets_bloc.dart';
import '../widgets/budget_details_sheet.dart';

Category _resolveCategory(String categoryId, List<Category> categories) {
  return categories.firstWhere(
    (c) => c.id == categoryId,
    orElse: () => CategoryModel(
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
    appBar: AppBar(title: Text(context.l10n.budgets)),
    floatingActionButton: FloatingActionButton.extended(
      heroTag: 'budgets_fab',
      onPressed: () => _openForm(context, null, availableCategories),
      icon: const Icon(Icons.add),
      label: Text(context.l10n.newBudget),
    ),
    body: BlocBuilder<BudgetsBloc, BudgetsState>(
      builder: (context, state) => switch (state.status) {
        BudgetsStatus.initial || BudgetsStatus.loading => const LoadingView(),
        BudgetsStatus.failure => ErrorState(
          message: state.failure?.message ?? context.l10n.pleaseTryAgain,
          onRetry: () =>
              context.read<BudgetsBloc>().add(const BudgetsRequested()),
        ),
        BudgetsStatus.empty => EmptyState(
          title: context.l10n.noBudgets,
          message: context.l10n.noBudgetsMessage,
          action: FilledButton(
            onPressed: () => _openForm(context, null, availableCategories),
            child: Text(context.l10n.createBudget),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.small,
              AppSpacing.large,
              AppSpacing.pageBottom,
            ),
            itemCount: state.budgets.length,
            itemBuilder: (context, index) => _BudgetCard(
              budget: state.budgets[index],
              categories: availableCategories,
              onTap: () => _openBudgetDetails(
                context,
                state.budgets[index],
                _resolveCategory(
                  state.budgets[index].categoryId,
                  availableCategories,
                ),
              ),
              onEdit: () =>
                  _openForm(context, state.budgets[index], availableCategories),
              onDelete: () async =>
                  _deleteBudget(context, state.budgets[index]),
            ),
          ),
        ),
      },
    ),
  );

  Future<void> _openBudgetDetails(
    BuildContext context,
    Budget budget,
    Category category,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => BudgetDetailsSheet(
        budget: budget,
        category: category,
        onEdit: () {
          Navigator.pop(sheetContext);
          _openForm(context, budget, availableCategories);
        },
        onDelete: () async {
          Navigator.pop(sheetContext);
          await _deleteBudget(context, budget);
        },
      ),
    );
  }

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

  Future<void> _deleteBudget(BuildContext context, Budget budget) async {
    final cat = _resolveCategory(budget.categoryId, availableCategories);
    final confirmed = await showConfirmation(
      context,
      title: context.l10n.deleteBudgetQuestion,
      message: context.l10n.budgetWillBeRemoved(cat.localizedName(context)),
    );
    if (confirmed) {
      await HapticFeedback.mediumImpact();
      if (!context.mounted) return;
      context.read<BudgetsBloc>().add(BudgetDeleted(budget.id));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.budgetDeleted(cat.localizedName(context))),
          action: SnackBarAction(
            label: context.l10n.undo,
            onPressed: () async {
              await getIt<BudgetUseCases>().save(budget);
            },
          ),
        ),
      );
    }
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.categories,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Budget budget;
  final List<Category> categories;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cat = _resolveCategory(budget.categoryId, categories);
    final scheme = Theme.of(context).colorScheme;
    final color = budget.isExceeded
        ? scheme.error
        : budget.isWarning
        ? Colors.orange
        : scheme.primary;

    return Dismissible(
      key: ValueKey('dismiss-budget-${budget.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.section),
        child: Icon(Icons.delete, color: scheme.onErrorContainer),
      ),
      confirmDismiss: (_) => showConfirmation(
        context,
        title: context.l10n.deleteBudgetQuestion,
        message: context.l10n.budgetWillBeRemoved(cat.localizedName(context)),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        context.read<BudgetsBloc>().add(BudgetDeleted(budget.id));
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.budgetDeleted(cat.localizedName(context)),
            ),
            action: SnackBarAction(
              label: context.l10n.undo,
              onPressed: () async {
                await getIt<BudgetUseCases>().save(budget);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.medium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.largeExtra),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: cat.color.withValues(alpha: .15),
                      child: Icon(cat.icon, color: cat.color),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.localizedName(context),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            context.l10n.spentOfLimit(
                              formatMoney(budget.spent),
                              formatMoney(budget.limit),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 20),
                              const SizedBox(width: AppSpacing.smallMedium),
                              Text(context.l10n.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: scheme.error,
                              ),
                              const SizedBox(width: AppSpacing.smallMedium),
                              Text(
                                context.l10n.delete,
                                style: TextStyle(color: scheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.mediumLarge),
                LinearProgressIndicator(
                  value: budget.progress.clamp(0, 1),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  budget.isExceeded
                      ? context.l10n.limitExceededBy(
                          formatMoney(budget.spent - budget.limit),
                        )
                      : budget.isWarning
                      ? context.l10n.budgetOverEightyPercent
                      : context.l10n.remainingAmount(
                          formatMoney(budget.limit - budget.spent),
                        ),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
    categoryId =
        widget.budget?.categoryId ??
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
        AppSpacing.extraLarge,
        0,
        AppSpacing.extraLarge,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.extraLarge,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.budget == null
                    ? context.l10n.newBudget
                    : context.l10n.editBudget,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.large),
              DropdownButtonFormField<String>(
                initialValue: categoryId,
                decoration: InputDecoration(labelText: context.l10n.category),
                items: widget.categories
                    .where((c) => c.id != 'salary')
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.localizedName(context)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => categoryId = value!),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: limit,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.monthlyLimit,
                  prefixIcon: const Icon(Icons.currency_ruble),
                ),
                validator: (value) {
                  final number = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  return number == null || number <= 0
                      ? context.l10n.enterPositiveLimit
                      : null;
                },
              ),
              const SizedBox(height: AppSpacing.extraLarge),
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
                child: Text(context.l10n.save),
              ),
              if (widget.budget != null) ...[
                const SizedBox(height: AppSpacing.small),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showConfirmation(
                      context,
                      title: context.l10n.deleteBudgetQuestion,
                      message: context.l10n.limitWillBeRemoved,
                    );
                    if (confirmed && context.mounted) {
                      final budgetId = widget.budget!.id;
                      Navigator.pop(context);
                      context.read<BudgetsBloc>().add(BudgetDeleted(budgetId));
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    context.l10n.deleteBudget,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
