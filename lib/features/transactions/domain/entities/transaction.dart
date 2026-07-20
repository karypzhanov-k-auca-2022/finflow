import 'package:equatable/equatable.dart';
import '../../../categories/domain/entities/category.dart';

export '../../../categories/domain/entities/category.dart';

enum TransactionType { income, expense }

enum TransactionPeriod { all, month, threeMonths, sixMonths, year, customRange }

enum SortDirection { ascending, descending }

enum TransactionSort { date, amount }

class FinanceTransaction extends Equatable {
  const FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.note = '',
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final Category category;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinanceTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    Category? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FinanceTransaction(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    category: category ?? this.category,
    date: date ?? this.date,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    type,
    category,
    date,
    note,
    createdAt,
    updatedAt,
  ];
}
