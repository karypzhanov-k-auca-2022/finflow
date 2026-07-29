import '../../../../core/error/result.dart';
import '../entities/transaction.dart';

typedef TransactionsResult = ({
  List<FinanceTransaction> transactions,
  bool fromCache,
});

abstract interface class TransactionRepository {
  Stream<void> get onTransactionsChanged;
  Future<Result<TransactionsResult>> getTransactions({bool refresh = false});
  Future<Result<FinanceTransaction>> saveTransaction(
    FinanceTransaction transaction,
  );
  Future<Result<void>> deleteTransaction(String id);
  Future<Result<void>> clear();
  Future<Result<void>> reseed();
}
