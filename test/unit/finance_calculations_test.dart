import 'package:finflow/features/analytics/domain/usecases/calculate_analytics.dart';
import 'package:finflow/features/budgets/domain/entities/budget.dart';
import 'package:finflow/features/dashboard/domain/usecases/build_dashboard.dart';
import 'package:finflow/features/transactions/domain/entities/transaction.dart';
import 'package:finflow/features/transactions/domain/usecases/transaction_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers.dart';

void main() {
  final now = DateTime(2026, 7, 18);
  final values = [
    transaction(
      id: 'income',
      title: 'Зарплата',
      amount: 100000,
      type: TransactionType.income,
      category: AppCategory.salary,
      date: DateTime(2026, 7, 2),
    ),
    transaction(
      id: 'food',
      title: 'Магазин',
      amount: 12000,
      note: 'На неделю',
      date: DateTime(2026, 7, 10),
    ),
    transaction(
      id: 'cafe',
      title: 'Кафе',
      amount: 3000,
      category: AppCategory.cafe,
      date: DateTime(2026, 6, 10),
    ),
  ];

  test('рассчитывает баланс, доходы и расходы месяца', () {
    final data = buildDashboardData(values, const [], now: now);
    expect(data.balance, 85000);
    expect(data.monthlyIncome, 100000);
    expect(data.monthlyExpense, 12000);
  });

  test('фильтрует по тексту, типу и категории', () {
    final result = filterTransactions(
      values,
      const TransactionFilter(
        query: 'неделю',
        type: TransactionType.expense,
        category: AppCategory.groceries,
      ),
    );
    expect(result.map((e) => e.id), ['food']);
  });

  test('сортирует по сумме по возрастанию', () {
    final result = filterTransactions(
      values,
      const TransactionFilter(
        sort: TransactionSort.amount,
        direction: SortDirection.ascending,
      ),
    );
    expect(result.map((e) => e.amount), [3000, 12000, 100000]);
  });

  test('определяет прогресс, предупреждение и превышение бюджета', () {
    const warning = Budget(
      id: '1',
      categoryId: AppCategory.cafe,
      limit: 1000,
      spent: 850,
      month: 7,
      year: 2026,
    );
    const exceeded = Budget(
      id: '2',
      categoryId: AppCategory.cafe,
      limit: 1000,
      spent: 1200,
      month: 7,
      year: 2026,
    );
    expect(warning.progress, .85);
    expect(warning.isWarning, isTrue);
    expect(exceeded.isExceeded, isTrue);
  });

  test('рассчитывает аналитику и топ-категорию', () {
    final data = calculateAnalytics(values, months: 2, now: now);
    expect(data.byCategory[AppCategory.groceries], 12000);
    expect(data.topCategory, AppCategory.groceries);
    expect(data.averageMonthly, 7500);
  });
}
