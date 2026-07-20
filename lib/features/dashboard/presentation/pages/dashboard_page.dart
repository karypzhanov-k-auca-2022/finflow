import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/category_x.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/state_views.dart';
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
          tooltip: 'Обновить',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/transactions/new'),
      icon: const Icon(Icons.add),
      label: const Text('Операция'),
    ),
    body: BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) => switch (state.status) {
        DashboardStatus.initial ||
        DashboardStatus.loading => const LoadingView(),
        DashboardStatus.failure => ErrorState(
          message: state.failure?.message ?? 'Попробуйте ещё раз',
          onRetry: () =>
              context.read<DashboardBloc>().add(const DashboardRequested()),
        ),
        DashboardStatus.empty => EmptyState(
          title: 'Пока нет операций',
          message:
              'Добавьте первую транзакцию — здесь появится обзор финансов.',
          action: FilledButton.icon(
            onPressed: () => context.push('/transactions/new'),
            icon: const Icon(Icons.add),
            label: const Text('Добавить'),
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
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Текущий баланс',
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
                          label: 'Доходы',
                          value: data.monthlyIncome,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: 'Расходы',
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
                    'Бюджет месяца',
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
                    '${formatMoney(data.monthlyExpense)} из ${formatMoney(data.budgetLimit)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Расходы по категориям',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: data.expensesByCategory.isEmpty
                ? const EmptyState(
                    title: 'Нет расходов',
                    message: 'За этот месяц расходов ещё не было.',
                  )
                : PieChart(
                    PieChartData(
                      centerSpaceRadius: 46,
                      sectionsSpace: 3,
                      sections: data.expensesByCategory.entries
                          .map(
                            (entry) => PieChartSectionData(
                              value: entry.value,
                              title: entry.key.label,
                              radius: 68,
                              color: entry.key.color,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Последние операции',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('Все'),
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
