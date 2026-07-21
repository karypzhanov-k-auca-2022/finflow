import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../categories/domain/usecases/category_use_cases.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_use_cases.dart';
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
    title: const Text('Transactions'),
      actions: [
        IconButton(
          onPressed: _showFilters,
          icon: const Icon(Icons.tune),
        tooltip: 'Filters',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'transactions_fab',
      onPressed: () => context.push('/transactions/new'),
      tooltip: 'Add transaction',
      child: const Icon(Icons.add),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: TextField(
            controller: search,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by title or note',
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
                message: state.failure?.message ?? 'Please try again',
                onRetry: () => context.read<TransactionsBloc>().add(
                  const TransactionsRequested(),
                ),
              ),
              TransactionsStatus.empty => EmptyState(
                title: 'No transactions',
                message: 'Add your first transaction to start tracking.',
                action: FilledButton(
                  onPressed: () => context.push('/transactions/new'),
                  child: const Text('Add'),
                ),
              ),
              TransactionsStatus.success when state.visible.isEmpty =>
                const EmptyState(
                  title: 'Nothing found',
                  message: 'Change the search query or filters.',
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
              20,
              0,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
 'Filters & sorting',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SegmentedButton<TransactionType?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('All')),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expenses'),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<Category?>(
                  initialValue: draft.category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                    child: Text('All categories'),
                    ),
                    ...availableCategories.map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionPeriod>(
                  initialValue: draft.period,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: TransactionPeriod.all,
                      child: Text('All time'),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.month,
                      child: Text('Current month'),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.threeMonths,
                      child: Text('3 months'),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.sixMonths,
                      child: Text('6 months'),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.year,
                      child: Text('Year'),
                    ),
                    DropdownMenuItem(
                      value: TransactionPeriod.customRange,
                      child: Text('Select range'),
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
                  const SizedBox(height: 8),
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
                          : 'Select date range',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TransactionSort>(
                        initialValue: draft.sort,
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TransactionSort.date,
                            child: Text('Date'),
                          ),
                          DropdownMenuItem(
                            value: TransactionSort.amount,
                            child: Text('Amount'),
                          ),
                        ],
                        onChanged: (value) => setModalState(
                          () => draft = draft.copyWith(sort: value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                tooltip: 'Direction',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context, draft),
                  child: const Text('Apply'),
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
                    padding: const EdgeInsets.only(right: 16, bottom: 4),
                    child: TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear filters'),
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
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is DateTime) {
            return Padding(
              key: ValueKey('header-$item'),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
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
              padding: const EdgeInsets.only(right: 24),
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            confirmDismiss: (_) => showConfirmation(
              context,
              title: 'Delete transaction?',
              message: '"${tx.title}" cannot be restored.',
            ),
            onDismissed: (_) => context.read<TransactionsBloc>().add(
              TransactionDeleteRequested(tx.id),
            ),
            child: TransactionTile(
              transaction: tx,
              onTap: () => context.push('/transactions/${tx.id}/edit'),
            ),
          );
        },
      ),
    );
  }
}
