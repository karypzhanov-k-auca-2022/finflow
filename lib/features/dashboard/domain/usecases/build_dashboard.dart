import '../../../budgets/domain/entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/dashboard_data.dart';

DashboardData buildDashboardData(
  List<FinanceTransaction> transactions,
  List<Budget> budgets, {
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final balance = transactions.fold<double>(
    0,
    (sum, item) =>
        sum +
        (item.type == TransactionType.income ? item.amount : -item.amount),
  );
  final monthly = transactions.where(
    (item) =>
        item.date.month == current.month && item.date.year == current.year,
  );
  final income = monthly
      .where((item) => item.type == TransactionType.income)
      .fold<double>(0, (sum, item) => sum + item.amount);
  final expenses = monthly
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
      .where((item) => item.month == current.month && item.year == current.year)
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
