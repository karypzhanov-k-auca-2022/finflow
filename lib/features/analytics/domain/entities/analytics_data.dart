import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction.dart';

class MonthlyExpense extends Equatable {
  const MonthlyExpense(this.month, this.amount);
  final DateTime month;
  final double amount;
  @override
  List<Object?> get props => [month, amount];
}

class AnalyticsData extends Equatable {
  const AnalyticsData({
    required this.monthlyExpenses,
    required this.byCategory,
    required this.averageMonthly,
    this.topCategory,
  });
  final List<MonthlyExpense> monthlyExpenses;
  final Map<AppCategory, double> byCategory;
  final double averageMonthly;
  final AppCategory? topCategory;
  @override
  List<Object?> get props => [
    monthlyExpenses,
    byCategory,
    averageMonthly,
    topCategory,
  ];
}
