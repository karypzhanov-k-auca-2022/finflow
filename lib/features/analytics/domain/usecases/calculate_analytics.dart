import '../../../transactions/domain/entities/transaction.dart';
import '../entities/analytics_data.dart';

AnalyticsData calculateAnalytics(
  List<FinanceTransaction> source, {
  int months = 6,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final starts = List.generate(
    months,
    (index) => DateTime(current.year, current.month - (months - 1 - index), 1),
  );
  final expenses = source
      .where(
        (item) =>
            item.type == TransactionType.expense &&
            !item.date.isBefore(starts.first),
      )
      .toList();
  final monthly = starts
      .map(
        (start) => MonthlyExpense(
          start,
          expenses
              .where(
                (item) =>
                    item.date.year == start.year &&
                    item.date.month == start.month,
              )
              .fold<double>(0, (sum, item) => sum + item.amount),
        ),
      )
      .toList();
  final byCategory = <Category, double>{};
  for (final item in expenses) {
    byCategory.update(
      item.category,
      (value) => value + item.amount,
      ifAbsent: () => item.amount,
    );
  }
  Category? top;
  if (byCategory.isNotEmpty) {
    top = byCategory.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
  final total = monthly.fold<double>(0, (sum, item) => sum + item.amount);
  return AnalyticsData(
    monthlyExpenses: monthly,
    byCategory: byCategory,
    averageMonthly: months == 0 ? 0 : total / months,
    topCategory: top,
  );
}
