import 'package:finflow/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:finflow/features/budgets/data/models/budget_model.dart';
import 'package:finflow/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finflow/features/transactions/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test('transaction storage is isolated by Firebase user id', () async {
    final dataSource = TransactionLocalDataSourceImpl(preferences);
    final first = TransactionModel.fromEntity(
      transaction(id: 'first', title: 'First user'),
    );
    final second = TransactionModel.fromEntity(
      transaction(id: 'second', title: 'Second user'),
    );

    await dataSource.saveTransaction(first, 'uid-1');
    await dataSource.saveTransaction(second, 'uid-2');

    expect(await dataSource.getTransactions('uid-1'), [first]);
    expect(await dataSource.getTransactions('uid-2'), [second]);
  });

  test('budget storage is isolated by Firebase user id', () async {
    final dataSource = BudgetLocalDataSourceImpl(preferences);
    const first = BudgetModel(
      id: 'first',
      categoryId: 'groceries',
      limit: 100,
      month: 8,
      year: 2026,
    );
    const second = BudgetModel(
      id: 'second',
      categoryId: 'transport',
      limit: 200,
      month: 8,
      year: 2026,
    );

    await dataSource.saveBudget(first, 'uid-1');
    await dataSource.saveBudget(second, 'uid-2');

    expect(await dataSource.getBudgets('uid-1'), [first]);
    expect(await dataSource.getBudgets('uid-2'), [second]);
  });
}
