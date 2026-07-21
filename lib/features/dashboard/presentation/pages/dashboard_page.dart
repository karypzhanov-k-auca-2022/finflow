import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FinFlow'),
      actions: [
        IconButton(
          onPressed: () => context.read<DashboardBloc>().add(
            const DashboardRequested(refresh: true),
          ),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      heroTag: 'dashboard_fab',
      onPressed: () => context.push('/transactions/new'),
      icon: const Icon(Icons.add),
      label: const Text('Add transaction'),
    ),
    body: BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) => switch (state.status) {
        DashboardStatus.initial ||
        DashboardStatus.loading => const LoadingView(),
        DashboardStatus.failure => ErrorState(
          message: state.failure?.message ?? 'Please try again',
          onRetry: () =>
              context.read<DashboardBloc>().add(const DashboardRequested()),
        ),
        DashboardStatus.empty => EmptyState(
          title: 'No transactions yet',
          message:
              'Add your first transaction — an overview will appear here.',
          action: FilledButton.icon(
            onPressed: () => context.push('/transactions/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        DashboardStatus.success => _DashboardContent(state: state),
      },
    ),
  );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});
  final DashboardState state;
  @override
  Widget build(BuildContext context) {
    final data = state.data!;
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(
          const DashboardRequested(refresh: true),
        );
        await context.read<DashboardBloc>().stream.firstWhere(
          (value) => value.status != DashboardStatus.loading,
        );
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _PeriodSelector(state: state),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current balance',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  CurrencyText(
                    data.balance,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: 'Income',
                          value: data.monthlyIncome,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: 'Expenses',
                          value: data.monthlyExpense,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget for period',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: data.budgetProgress.clamp(0, 1),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatMoney(data.monthlyExpense)} of ${formatMoney(data.budgetLimit)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Expenses by category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (data.expensesByCategory.isEmpty)
            const SizedBox(
              height: 220,
              child: EmptyState(
                title: 'No expenses',
                message: 'No expenses for the selected period yet.',
              ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: 270,
                  centerSpaceRadius: 46,
                  sectionsSpace: 3,
                  sections: data.expensesByCategory.entries
                      .map(
                        (entry) => PieChartSectionData(
                          value: entry.value,
                          showTitle: false,
                          radius: 68,
                          color: entry.key.color,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: data.expensesByCategory.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                final percentage =
                    data.monthlyExpense > 0 ? (amount / data.monthlyExpense) * 100 : 0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${category.name} (${percentage.toStringAsFixed(0)}%)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatMoney(amount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('All'),
              ),
            ],
          ),
          Card(
            child: Column(
              children: data.recent
                  .map(
                    (item) => TransactionTile(
                      transaction: item,
                      onTap: () =>
                          context.push('/transactions/${item.id}/edit'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final period = state.period;
    final from = state.from;
    final to = state.to;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
          label: const Text('Month'),
            selected: period == TransactionPeriod.month,
            onSelected: (_) => context.read<DashboardBloc>().add(
                  const DashboardPeriodChanged(period: TransactionPeriod.month),
                ),
          ),
          const SizedBox(width: 8),
          FilterChip(
          label: const Text('3 mo'),
            selected: period == TransactionPeriod.threeMonths,
            onSelected: (_) => context.read<DashboardBloc>().add(
                  const DashboardPeriodChanged(period: TransactionPeriod.threeMonths),
                ),
          ),
          const SizedBox(width: 8),
          FilterChip(
          label: const Text('6 mo'),
            selected: period == TransactionPeriod.sixMonths,
            onSelected: (_) => context.read<DashboardBloc>().add(
                  const DashboardPeriodChanged(period: TransactionPeriod.sixMonths),
                ),
          ),
          const SizedBox(width: 8),
          FilterChip(
          label: const Text('Year'),
            selected: period == TransactionPeriod.year,
            onSelected: (_) => context.read<DashboardBloc>().add(
                  const DashboardPeriodChanged(period: TransactionPeriod.year),
                ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(Icons.date_range, size: 16),
            label: Text(
              period == TransactionPeriod.customRange && from != null && to != null
                  ? '${formatDate(from)} — ${formatDate(to)}'
                  : 'Select range',
            ),
            selected: period == TransactionPeriod.customRange,
            onSelected: (_) async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: from != null && to != null
                    ? DateTimeRange(start: from, end: to)
                    : null,
              );
              if (range != null && context.mounted) {
                context.read<DashboardBloc>().add(
                      DashboardPeriodChanged(
                        period: TransactionPeriod.customRange,
                        from: range.start,
                        to: range.end,
                      ),
                    );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 4),
      CurrencyText(
        value,
        color: color,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    ],
  );
}
