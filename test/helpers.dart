import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/transactions/domain/entities/transaction.dart';
import 'package:finflow/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

FinanceTransaction transaction({
  String id = '1',
  String title = 'Продукты',
  double amount = 1000,
  TransactionType type = TransactionType.expense,
  AppCategory category = AppCategory.groceries,
  DateTime? date,
  String note = '',
}) {
  final valueDate = date ?? DateTime(2026, 7, 10);
  return FinanceTransaction(
    id: id,
    title: title,
    amount: amount,
    type: type,
    category: category,
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
