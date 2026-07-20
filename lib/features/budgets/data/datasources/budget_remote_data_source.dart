import 'package:dio/dio.dart';
import '../models/budget_model.dart';

abstract interface class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<void> saveBudget(BudgetModel budget, {required bool isNew});
  Future<void> deleteBudget(String id);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  BudgetRemoteDataSourceImpl(this.dio);
  final Dio dio;

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final response = await dio.get<List<dynamic>>('/budgets');
    return (response.data ?? [])
        .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveBudget(BudgetModel budget, {required bool isNew}) => isNew
      ? dio.post<void>('/budgets', data: budget.toJson())
      : dio.put<void>('/budgets/${budget.id}', data: budget.toJson());

  @override
  Future<void> deleteBudget(String id) => dio.delete<void>('/budgets/$id');
}
