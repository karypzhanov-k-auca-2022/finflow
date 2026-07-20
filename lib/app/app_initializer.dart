import '../features/budgets/data/datasources/budget_local_data_source.dart';
import '../features/transactions/data/datasources/transaction_local_data_source.dart';

class AppInitializer {
  const AppInitializer(this.transactions, this.budgets);
  final TransactionLocalDataSource transactions;
  final BudgetLocalDataSource budgets;
  Future<void> initialize() async {
    await transactions.seedIfNeeded();
    await budgets.seedIfNeeded();
  }
}
