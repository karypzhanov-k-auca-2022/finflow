import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/app_routes.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../app/dependency_injection.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/extensions/l10n_x.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/utils/category_x.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../../categories/data/datasources/category_local_data_source.dart';
import '../../../../categories/domain/usecases/category_use_cases.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import '../bloc/transactions_bloc.dart';
import '../widgets/transaction_tile.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final search = TextEditingController();
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
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.transactionsTitle),
      actions: [
        IconButton(
          onPressed: _showFilters,
          icon: const Icon(Icons.tune),
          tooltip: context.l10n.filters,
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'transactions_fab',
      onPressed: () => context.push(AppRoutes.newTransaction),
      tooltip: context.l10n.addTransaction,
      child: const Icon(Icons.add),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.tiny,
            AppSpacing.large,
            AppSpacing.medium,
          ),
          child: TextField(
            controller: search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: context.l10n.searchTransactions,
            ),
            onChanged: (value) {
              final bloc = context.read<TransactionsBloc>();
              bloc.add(
                TransactionFilterChanged(
                  bloc.state.filter.copyWith(query: value),
                ),
              );
            },
          ),
        ),
        _ActiveFilters(
          onClear: () {
            search.clear();
            context.read<TransactionsBloc>().add(
              const TransactionFilterChanged(TransactionFilter()),
            );
          },
        ),
        Expanded(
          child: BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, state) => switch (state.status) {
              TransactionsStatus.initial ||
              TransactionsStatus.loading => const LoadingView(),
              TransactionsStatus.failure => ErrorState(
                message: state.failure?.message ?? context.l10n.pleaseTryAgain,
                onRetry: () => context.read<TransactionsBloc>().add(
                  const TransactionsRequested(),
                ),
              ),
              TransactionsStatus.empty => EmptyState(
                title: context.l10n.noTransactions,
                message: context.l10n.noTransactionsMessage,
                action: FilledButton(
                  onPressed: () => context.push(AppRoutes.newTransaction),
                  child: Text(context.l10n.add),
                ),
              ),
              TransactionsStatus.success when state.visible.isEmpty =>
                EmptyState(
                  title: context.l10n.nothingFound,
                  message: context.l10n.nothingFoundMessage,
                ),
              TransactionsStatus.success => _TransactionList(
                values: state.visible,
              ),
            },
          ),
        ),
      ],
    ),
  );

  Future<void> _showFilters() async {
    final bloc = context.read<TransactionsBloc>();
    var draft = bloc.state.filter;
    final result = await showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.extraLarge,
              0,
              AppSpacing.extraLarge,
              MediaQuery.viewInsetsOf(context).bottom + AppSpacing.extraLarge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.filtersAndSorting,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.large),
                SegmentedButton<TransactionType?>(
                  segments: [
                    ButtonSegment(value: null, label: Text(context.l10n.all)),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text(context.l10n.income),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(context.l10n.expenses),
                    ),
                  ],
                  selected: {draft.type},
                  onSelectionChanged: (value) => setModalState(
                    () => draft = draft.copyWith(
                      type: value.first,
                      clearType: value.first == null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<Category?>(
                  initialValue: draft.category,
                  decoration: InputDecoration(labelText: context.l10n.category),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(context.l10n.allCategories),
                    ),
                    ...availableCategories.map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.localizedName(context)),
                      ),
                    ),
                  ],
                  onChanged: (value) => setModalState(
                    () => draft = draft.copyWith(
                      category: value,
                      clearCategory: value == null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<TransactionPeriod>(
                  initialValue: draft.period,
                  decoration: InputDecoration(
                    labelText: context.l10n.period,
                    prefixIcon: const Icon(Icons.date_range),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: TransactionPeriod.all,
                      child: Text(context.l10n.allTime),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.month,
                      child: Text(context.l10n.currentMonth),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.threeMonths,
                      child: Text(context.l10n.threeMonths),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.sixMonths,
                      child: Text(context.l10n.sixMonths),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.year,
                      child: Text(context.l10n.year),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.customRange,
                      child: Text(context.l10n.selectRange),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    if (value == TransactionPeriod.customRange) {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: draft.from != null && draft.to != null
                            ? DateTimeRange(start: draft.from!, end: draft.to!)
                            : null,
                      );
                      if (range != null) {
                        setModalState(
                          () => draft = draft.copyWith(
                            period: TransactionPeriod.customRange,
                            from: range.start,
                            to: range.end,
                          ),
                        );
                      }
                    } else {
                      setModalState(
                        () => draft = draft.copyWith(
                          period: value,
                          clearFrom: true,
                          clearTo: true,
                        ),
                      );
                    }
                  },
                ),
                if (draft.period == TransactionPeriod.customRange) ...[
                  const SizedBox(height: AppSpacing.small),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: draft.from != null && draft.to != null
                            ? DateTimeRange(start: draft.from!, end: draft.to!)
                            : null,
                      );
                      if (range != null) {
                        setModalState(
                          () => draft = draft.copyWith(
                            period: TransactionPeriod.customRange,
                            from: range.start,
                            to: range.end,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit_calendar),
                    label: Text(
                      draft.from != null && draft.to != null
                          ? '${formatDate(draft.from!)} — ${formatDate(draft.to!)}'
                          : context.l10n.selectDateRange,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.medium),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TransactionSort>(
                        initialValue: draft.sort,
                        decoration: InputDecoration(
                          labelText: context.l10n.sortBy,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: TransactionSort.date,
                            child: Text(context.l10n.date),
                          ),
                          DropdownMenuItem(
                            value: TransactionSort.amount,
                            child: Text(context.l10n.amount),
                          ),
                        ],
                        onChanged: (value) => setModalState(
                          () => draft = draft.copyWith(sort: value),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    IconButton.filledTonal(
                      onPressed: () => setModalState(
                        () => draft = draft.copyWith(
                          direction: draft.direction == SortDirection.ascending
                              ? SortDirection.descending
                              : SortDirection.ascending,
                        ),
                      ),
                      icon: Icon(
                        draft.direction == SortDirection.ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      tooltip: context.l10n.direction,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.extraLarge),
                FilledButton(
                  onPressed: () => Navigator.pop(context, draft),
                  child: Text(context.l10n.apply),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) bloc.add(TransactionFilterChanged(result));
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.onClear});
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionsBloc, TransactionsState>(
        buildWhen: (a, b) => a.filter != b.filter,
        builder: (context, state) {
          final active =
              state.filter.type != null ||
              state.filter.category != null ||
              state.filter.period != TransactionPeriod.all ||
              state.filter.from != null ||
              state.filter.query.isNotEmpty;
          return active
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.large,
                      bottom: AppSpacing.tiny,
                    ),
                    child: TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear, size: 18),
                      label: Text(context.l10n.clearFilters),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      );
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.values});
  final List<FinanceTransaction> values;
  @override
  Widget build(BuildContext context) {
    final items = <Object>[];
    DateTime? previous;
    for (final item in values) {
      final day = DateTime(item.date.year, item.date.month, item.date.day);
      if (day != previous) {
        items.add(day);
        previous = day;
      }
      items.add(item);
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransactionsBloc>().add(
          const TransactionsRequested(refresh: true),
        );
        await context.read<TransactionsBloc>().stream.firstWhere(
          (state) => state.status != TransactionsStatus.loading,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSpacing.pageBottom),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is DateTime) {
            return Padding(
              key: ValueKey('header-$item'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.largeExtra,
                AppSpacing.large,
                AppSpacing.compact,
              ),
              child: Text(
                formatDate(item),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            );
          }
          final tx = item as FinanceTransaction;
          return Dismissible(
            key: ValueKey('dismiss-${tx.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.section),
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            confirmDismiss: (_) => showConfirmation(
              context,
              title: context.l10n.deleteTransactionQuestion,
              message: context.l10n.transactionCannotBeRestored(tx.title),
            ),
            onDismissed: (_) {
              HapticFeedback.mediumImpact();
              context.read<TransactionsBloc>().add(
                TransactionDeleteRequested(tx.id),
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.transactionDeleted(tx.title)),
                  action: SnackBarAction(
                    label: context.l10n.undo,
                    onPressed: () async {
                      await getIt<TransactionUseCases>().save(tx);
                    },
                  ),
                ),
              );
            },
            child: TransactionTile(
              transaction: tx,
              onTap: () => context.push(AppRoutes.transactionEdit(tx.id)),
            ),
          );
        },
      ),
    );
  }
}
