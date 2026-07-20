import '../../../budgets/domain/entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../entities/dashboard_data.dart';

DashboardData buildDashboardData(
  List<FinanceTransaction> transactions,
  List<Budget> budgets, {
  DateTime? now,
  TransactionPeriod period = TransactionPeriod.month,
  DateTime? from,
  DateTime? to,
}) {
  final current = now ?? DateTime.now();
  final filter = TransactionFilter(period: period, from: from, to: to);
  final (start, end) = filter.getEffectiveRange(now: current);

  final balance = transactions.fold<double>(
    0,
    (sum, item) =>
        sum +
        (item.type == TransactionType.income ? item.amount : -item.amount),
  );

  final periodTransactions = transactions.where((item) {
    final matchesStart = start == null || !item.date.isBefore(start);
    final matchesEnd = end == null || !item.date.isAfter(end);
    return matchesStart && matchesEnd;
  });

  final income = periodTransactions
      .where((item) => item.type == TransactionType.income)
      .fold<double>(0, (sum, item) => sum + item.amount);

  final expenses = periodTransactions
      .where((item) => item.type == TransactionType.expense)
      .toList();

  final expense = expenses.fold<double>(0, (sum, item) => sum + item.amount);

  final byCategory = <Category, double>{};
  for (final item in expenses) {
    byCategory.update(
      item.category,
      (value) => value + item.amount,
      ifAbsent: () => item.amount,
    );
  }

  final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

  final limit = budgets
      .where((item) {
        if (start != null && end != null) {
          final bDate = DateTime(item.year, item.month, 1);
          return (bDate.year > start.year || (bDate.year == start.year && bDate.month >= start.month)) &&
                 (bDate.year < end.year || (bDate.year == end.year && bDate.month <= end.month));
        }
        return item.month == current.month && item.year == current.year;
      })
      .fold<double>(0, (sum, item) => sum + item.limit);

  return DashboardData(
    balance: balance,
    monthlyIncome: income,
    monthlyExpense: expense,
    budgetLimit: limit,
    recent: sorted.take(5).toList(),
    expensesByCategory: byCategory,
  );
}
