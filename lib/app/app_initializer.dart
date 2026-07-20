import '../features/budgets/data/datasources/budget_local_data_source.dart';
import '../features/categories/data/datasources/category_local_data_source.dart';
import '../features/transactions/data/datasources/transaction_local_data_source.dart';

class AppInitializer {
  const AppInitializer(this.categories, this.transactions, this.budgets);
  final CategoryLocalDataSource categories;
  final TransactionLocalDataSource transactions;
  final BudgetLocalDataSource budgets;

  Future<void> initialize() async {
    await categories.seedIfNeeded();
    await transactions.seedIfNeeded();
    await budgets.seedIfNeeded();
  }
}
