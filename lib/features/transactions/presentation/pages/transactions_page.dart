import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/category_x.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
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
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Транзакции'),
      actions: [
        IconButton(
          onPressed: _showFilters,
          icon: const Icon(Icons.tune),
          tooltip: 'Фильтры',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.push('/transactions/new'),
      tooltip: 'Добавить транзакцию',
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
              hintText: 'Поиск по названию или заметке',
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
                message: state.failure?.message ?? 'Попробуйте ещё раз',
                onRetry: () => context.read<TransactionsBloc>().add(
                  const TransactionsRequested(),
                ),
              ),
              TransactionsStatus.empty => EmptyState(
                title: 'Нет транзакций',
                message: 'Добавьте первую операцию, чтобы начать учёт.',
                action: FilledButton(
                  onPressed: () => context.push('/transactions/new'),
                  child: const Text('Добавить'),
                ),
              ),
              TransactionsStatus.success when state.visible.isEmpty =>
                const EmptyState(
                  title: 'Ничего не найдено',
                  message: 'Измените поисковый запрос или фильтры.',
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
                  'Фильтры и сортировка',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SegmentedButton<TransactionType?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Все')),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Доходы'),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Расходы'),
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
                DropdownButtonFormField<AppCategory?>(
                  initialValue: draft.category,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Все категории'),
                    ),
                    ...AppCategory.values.map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            initialDateRange:
                                draft.from != null && draft.to != null
                                ? DateTimeRange(
                                    start: draft.from!,
                                    end: draft.to!,
                                  )
                                : null,
                          );
                          if (range != null) {
                            setModalState(
                              () => draft = draft.copyWith(
                                from: range.start,
                                to: range.end,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          draft.from == null
                              ? 'Период'
                              : '${formatDate(draft.from!)} — ${formatDate(draft.to!)}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TransactionSort>(
                        initialValue: draft.sort,
                        decoration: const InputDecoration(
                          labelText: 'Сортировать по',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TransactionSort.date,
                            child: Text('Дате'),
                          ),
                          DropdownMenuItem(
                            value: TransactionSort.amount,
                            child: Text('Сумме'),
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
                      tooltip: 'Направление',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context, draft),
                  child: const Text('Применить'),
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
                      label: const Text('Сбросить фильтры'),
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
              title: 'Удалить транзакцию?',
              message: '«${tx.title}» нельзя будет восстановить.',
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
