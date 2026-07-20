import '../../domain/entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.limit,
    required super.month,
    required super.year,
    super.spent,
  });

  factory BudgetModel.fromEntity(Budget value) => BudgetModel(
    id: value.id,
    categoryId: value.categoryId,
    limit: value.limit,
    spent: value.spent,
    month: value.month,
    year: value.year,
  );

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
    id: json['id'] as String,
    categoryId: AppCategory.values.byName(json['categoryId'] as String),
    limit: (json['limit'] as num).toDouble(),
    spent: (json['spent'] as num? ?? 0).toDouble(),
    month: json['month'] as int,
    year: json['year'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId.name,
    'limit': limit,
    'spent': spent,
    'month': month,
    'year': year,
  };
}
