import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction.dart';

class DashboardData extends Equatable {
  const DashboardData({
    required this.balance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.budgetLimit,
    required this.recent,
    required this.expensesByCategory,
  });
  final double balance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double budgetLimit;
  final List<FinanceTransaction> recent;
  final Map<AppCategory, double> expensesByCategory;
  double get budgetProgress =>
      budgetLimit <= 0 ? 0 : monthlyExpense / budgetLimit;

  @override
  List<Object?> get props => [
    balance,
    monthlyIncome,
    monthlyExpense,
    budgetLimit,
    recent,
    expensesByCategory,
  ];
}
