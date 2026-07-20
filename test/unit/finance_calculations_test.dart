import 'package:finflow/features/analytics/domain/usecases/calculate_analytics.dart';
import 'package:finflow/features/budgets/domain/entities/budget.dart';
import 'package:finflow/features/categories/data/models/category_model.dart';
import 'package:finflow/features/dashboard/domain/usecases/build_dashboard.dart';
import 'package:finflow/features/transactions/data/models/transaction_model.dart';
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
      category: testSalaryCategory,
      date: DateTime(2026, 7, 2),
    ),
    transaction(
      id: 'food',
      title: 'Магазин',
      amount: 12000,
      note: 'На неделю',
      category: testGroceriesCategory,
      date: DateTime(2026, 7, 10),
    ),
    transaction(
      id: 'cafe',
      title: 'Кафе',
      amount: 3000,
      category: testCafeCategory,
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
      TransactionFilter(
        query: 'неделю',
        type: TransactionType.expense,
        category: testGroceriesCategory,
      ),
    );
    expect(result.map((e) => e.id), ['food']);
  });

  test('фильтрует по кастомному периоду customRange', () {
    final result = filterTransactions(
      values,
      TransactionFilter(
        period: TransactionPeriod.customRange,
        from: DateTime(2026, 6, 1),
        to: DateTime(2026, 6, 30),
      ),
    );
    expect(result.map((e) => e.id), ['cafe']);
  });

  test('рассчитывает дашборд для выбранного диапазона customRange', () {
    final data = buildDashboardData(
      values,
      const [],
      now: now,
      period: TransactionPeriod.customRange,
      from: DateTime(2026, 6, 1),
      to: DateTime(2026, 6, 30),
    );
    expect(data.monthlyExpense, 3000);
    expect(data.monthlyIncome, 0);
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
      categoryId: 'cafe',
      limit: 1000,
      spent: 850,
      month: 7,
      year: 2026,
    );
    const exceeded = Budget(
      id: '2',
      categoryId: 'cafe',
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
    expect(data.byCategory[testGroceriesCategory], 12000);
    expect(data.topCategory, testGroceriesCategory);
    expect(data.averageMonthly, 7500);
  });

  test('CategoryModel correctly serializes and deserializes', () {
    const model = CategoryModel(
      id: 'cat_test',
      name: 'Тест',
      iconCodePoint: 12345,
      colorValue: 0xFF123456,
    );
    final json = model.toJson();
    expect(json['id'], 'cat_test');
    expect(json['name'], 'Тест');
    expect(json['iconCodePoint'], 12345);
    expect(json['colorValue'], 0xFF123456);

    final restored = CategoryModel.fromJson(json);
    expect(restored, model);
  });

  test('TransactionModel converts legacy string category enum into CategoryModel', () {
    final legacyJson = {
      'id': 'tx-legacy',
      'title': 'Старая транзакция',
      'amount': 500.0,
      'type': 'expense',
      'category': 'groceries',
      'date': '2026-07-10T00:00:00.000',
      'note': '',
      'createdAt': '2026-07-10T00:00:00.000',
      'updatedAt': '2026-07-10T00:00:00.000',
    };

    final model = TransactionModel.fromJson(legacyJson);
    expect(model.category.id, 'groceries');
    expect(model.category.name, 'Продукты');
    expect(model.category.iconCodePoint, isNotNull);
  });
}
