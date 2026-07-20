import '../../domain/entities/transaction.dart';

class TransactionModel extends FinanceTransaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.note,
  });

  factory TransactionModel.fromEntity(FinanceTransaction value) =>
      TransactionModel(
        id: value.id,
        title: value.title,
        amount: value.amount,
        type: value.type,
        category: value.category,
        date: value.date,
        note: value.note,
        createdAt: value.createdAt,
        updatedAt: value.updatedAt,
      );

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.byName(json['type'] as String),
        category: AppCategory.values.byName(json['category'] as String),
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'type': type.name,
    'category': category.name,
    'date': date.toIso8601String(),
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
