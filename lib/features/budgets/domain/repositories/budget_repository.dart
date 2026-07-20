import '../../../../core/error/result.dart';
import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Stream<void> get onBudgetsChanged;
  Future<Result<List<Budget>>> getBudgets({bool refresh = false});
  Future<Result<Budget>> saveBudget(Budget budget);
  Future<Result<void>> deleteBudget(String id);
  Future<Result<void>> clear();
  Future<Result<void>> reseed();
}
