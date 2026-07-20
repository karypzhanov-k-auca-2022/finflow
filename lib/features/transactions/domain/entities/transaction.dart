import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum AppCategory {
  salary,
  groceries,
  transport,
  rent,
  cafe,
  subscriptions,
  health,
  entertainment,
  transfers,
}

enum TransactionPeriod { all, month, threeMonths, sixMonths }

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
  final AppCategory category;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinanceTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    AppCategory? category,
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

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.colorValue,
  });
  final AppCategory id;
  final String name;
  final int icon;
  final TransactionType type;
  final int colorValue;

  @override
  List<Object?> get props => [id, name, icon, type, colorValue];
}
