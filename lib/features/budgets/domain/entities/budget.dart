import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
    required this.year,
    this.spent = 0,
  });
  final String id;
  final String categoryId;
  final double limit;
  final double spent;
  final int month;
  final int year;

  double get progress => limit <= 0 ? 0 : spent / limit;
  bool get isWarning => progress >= .8 && progress <= 1;
  bool get isExceeded => progress > 1;

  Budget copyWith({
    String? id,
    String? categoryId,
    double? limit,
    double? spent,
    int? month,
    int? year,
  }) => Budget(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    limit: limit ?? this.limit,
    spent: spent ?? this.spent,
    month: month ?? this.month,
    year: year ?? this.year,
  );

  @override
  List<Object?> get props => [id, categoryId, limit, spent, month, year];
}
