import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/transactions/domain/entities/transaction.dart';
import 'package:finflow/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

final testGroceriesCategory = defaultCategoryModels.firstWhere((c) => c.id == 'groceries');
final testSalaryCategory = defaultCategoryModels.firstWhere((c) => c.id == 'salary');
final testCafeCategory = defaultCategoryModels.firstWhere((c) => c.id == 'cafe');

FinanceTransaction transaction({
  String id = '1',
  String title = 'Продукты',
  double amount = 1000,
  TransactionType type = TransactionType.expense,
  Category? category,
  DateTime? date,
  String note = '',
}) {
  final valueDate = date ?? DateTime(2026, 7, 10);
  return FinanceTransaction(
    id: id,
    title: title,
    amount: amount,
    type: type,
    category: category ?? testGroceriesCategory,
    date: valueDate,
    note: note,
    createdAt: valueDate,
    updatedAt: valueDate,
  );
}

class MockTransactionRepository extends Mock implements TransactionRepository {
  @override
  Stream<void> get onTransactionsChanged => const Stream<void>.empty();
}

void stubLoad(
  MockTransactionRepository repository,
  List<FinanceTransaction> values,
) {
  when(
    () => repository.getTransactions(refresh: any(named: 'refresh')),
  ).thenAnswer((_) async => Success((transactions: values, fromCache: true)));
}
