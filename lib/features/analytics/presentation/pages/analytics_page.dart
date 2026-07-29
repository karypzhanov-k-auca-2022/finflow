import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/category_x.dart';
import '../../../../core/extensions/l10n_x.dart';
import '../../../../core/widgets/state_views.dart';
import '../bloc/analytics_bloc.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.analytics)),
    body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) => switch (state.status) {
        AnalyticsStatus.initial ||
        AnalyticsStatus.loading => const LoadingView(),
        AnalyticsStatus.failure => ErrorState(
          message: state.failure?.message ?? context.l10n.pleaseTryAgain,
          onRetry: () => context.read<AnalyticsBloc>().add(
            AnalyticsRequested(months: state.months),
          ),
        ),
        AnalyticsStatus.empty => EmptyState(
          title: context.l10n.notEnoughData,
          message: context.l10n.addExpensesForAnalytics,
        ),
        AnalyticsStatus.success => _AnalyticsContent(state: state),
      },
    ),
  );
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({required this.state});
  final AnalyticsState state;
  @override
  Widget build(BuildContext context) {
    final data = state.data!;
    final sortedCategories = data.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maximum = data.monthlyExpenses.fold<double>(
      1,
      (max, item) => item.amount > max ? item.amount : max,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        SegmentedButton<int>(
          segments: [
            ButtonSegment(value: 3, label: Text(context.l10n.threeMonths)),
            ButtonSegment(value: 6, label: Text(context.l10n.sixMonths)),
            ButtonSegment(value: 12, label: Text(context.l10n.year)),
          ],
          selected: {state.months},
          onSelectionChanged: (value) => context.read<AnalyticsBloc>().add(
            AnalyticsRequested(months: value.first),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: context.l10n.averageExpenses,
                value: formatMoney(data.averageMonthly),
                icon: Icons.insights_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: context.l10n.topCategory,
                value: data.topCategory?.localizedName(context) ?? '—',
                icon: Icons.star_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.monthlyExpenses,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 16, 12),
            child: SizedBox(
              height: 230,
              child: BarChart(
                BarChartData(
                  maxY: maximum * 1.2,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 ||
                              index >= data.monthlyExpenses.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              DateFormat.MMM(
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(data.monthlyExpenses[index].month),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < data.monthlyExpenses.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: data.monthlyExpenses[i].amount,
                            width: state.months == 12 ? 10 : 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.byCategory,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: sortedCategories
                .map(
                  (entry) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: entry.key.color.withValues(alpha: .15),
                      child: Icon(entry.key.icon, color: entry.key.color),
                    ),
                    title: Text(entry.key.localizedName(context)),
                    trailing: Text(
                      formatMoney(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
