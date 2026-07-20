import '../../../../core/error/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class BudgetUseCases {
  const BudgetUseCases(this.repository);
  final BudgetRepository repository;

  Stream<void> get onBudgetsChanged => repository.onBudgetsChanged;

  Future<Result<List<Budget>>> load({bool refresh = false}) =>
      repository.getBudgets(refresh: refresh);
  Future<Result<Budget>> save(Budget value) => repository.saveBudget(value);
  Future<Result<void>> delete(String id) => repository.deleteBudget(id);
  Future<Result<void>> clear() => repository.clear();
  Future<Result<void>> reseed() => repository.reseed();

  List<Budget> withSpent(
    List<Budget> budgets,
    List<FinanceTransaction> transactions,
  ) => budgets.map((budget) {
    final spent = transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.category == budget.categoryId &&
              item.date.month == budget.month &&
              item.date.year == budget.year,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
    return budget.copyWith(spent: spent);
  }).toList();
}
