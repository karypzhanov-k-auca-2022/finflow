import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/app_routes.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../app/dependency_injection.dart';
import '../../../../../core/extensions/l10n_x.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/state_views.dart';
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
    final result = await context.push<TransactionFilter>(
      AppRoutes.transactionFilters,
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
