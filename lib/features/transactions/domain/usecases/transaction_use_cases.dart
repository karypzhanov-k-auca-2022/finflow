import '../../../../core/error/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.category,
    this.from,
    this.to,
    this.sort = TransactionSort.date,
    this.direction = SortDirection.descending,
  });
  final String query;
  final TransactionType? type;
  final AppCategory? category;
  final DateTime? from;
  final DateTime? to;
  final TransactionSort sort;
  final SortDirection direction;

  TransactionFilter copyWith({
    String? query,
    TransactionType? type,
    bool clearType = false,
    AppCategory? category,
    bool clearCategory = false,
    DateTime? from,
    DateTime? to,
    TransactionSort? sort,
    SortDirection? direction,
  }) => TransactionFilter(
    query: query ?? this.query,
    type: clearType ? null : type ?? this.type,
    category: clearCategory ? null : category ?? this.category,
    from: from ?? this.from,
    to: to ?? this.to,
    sort: sort ?? this.sort,
    direction: direction ?? this.direction,
  );
}

List<FinanceTransaction> filterTransactions(
  List<FinanceTransaction> source,
  TransactionFilter filter,
) {
  final query = filter.query.trim().toLowerCase();
  final values = source.where((item) {
    final matchesQuery =
        query.isEmpty ||
        item.title.toLowerCase().contains(query) ||
        item.note.toLowerCase().contains(query);
    final matchesType = filter.type == null || item.type == filter.type;
    final matchesCategory =
        filter.category == null || item.category == filter.category;
    final matchesFrom =
        filter.from == null || !item.date.isBefore(filter.from!);
    final end = filter.to == null
        ? null
        : DateTime(
            filter.to!.year,
            filter.to!.month,
            filter.to!.day,
            23,
            59,
            59,
          );
    final matchesTo = end == null || !item.date.isAfter(end);
    return matchesQuery &&
        matchesType &&
        matchesCategory &&
        matchesFrom &&
        matchesTo;
  }).toList();
  values.sort((a, b) {
    final comparison = filter.sort == TransactionSort.date
        ? a.date.compareTo(b.date)
        : a.amount.compareTo(b.amount);
    return filter.direction == SortDirection.ascending
        ? comparison
        : -comparison;
  });
  return values;
}

class TransactionUseCases {
  const TransactionUseCases(this.repository);
  final TransactionRepository repository;

  Stream<void> get onTransactionsChanged => repository.onTransactionsChanged;

  Future<Result<TransactionsResult>> load({bool refresh = false}) =>
      repository.getTransactions(refresh: refresh);
  Future<Result<FinanceTransaction>> save(FinanceTransaction value) =>
      repository.saveTransaction(value);
  Future<Result<void>> delete(String id) => repository.deleteTransaction(id);
  Future<Result<void>> clear() => repository.clear();
  Future<Result<void>> reseed() => repository.reseed();
}
