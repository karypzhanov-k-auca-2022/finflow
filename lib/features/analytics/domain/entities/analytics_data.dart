import 'package:equatable/equatable.dart';
import '../../../categories/domain/entities/category.dart';

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
  final Map<Category, double> byCategory;
  final double averageMonthly;
  final Category? topCategory;
  @override
  List<Object?> get props => [
    monthlyExpenses,
    byCategory,
    averageMonthly,
    topCategory,
  ];
}
