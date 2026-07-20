import '../../../../core/error/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.category,
    this.period = TransactionPeriod.all,
    this.from,
    this.to,
    this.sort = TransactionSort.date,
    this.direction = SortDirection.descending,
  });

  final String query;
  final TransactionType? type;
  final Category? category;
  final TransactionPeriod period;
  final DateTime? from;
  final DateTime? to;
  final TransactionSort sort;
  final SortDirection direction;

  (DateTime?, DateTime?) getEffectiveRange({DateTime? now}) {
    final current = now ?? DateTime.now();
    switch (period) {
      case TransactionPeriod.all:
        final start = from != null ? DateTime(from!.year, from!.month, from!.day) : null;
        final end = to != null ? DateTime(to!.year, to!.month, to!.day, 23, 59, 59) : null;
        return (start, end);
      case TransactionPeriod.month:
        final start = DateTime(current.year, current.month, 1);
        final end = DateTime(current.year, current.month + 1, 0, 23, 59, 59);
        return (start, end);
      case TransactionPeriod.threeMonths:
        final start = DateTime(current.year, current.month - 2, 1);
        final end = DateTime(current.year, current.month + 1, 0, 23, 59, 59);
        return (start, end);
      case TransactionPeriod.sixMonths:
        final start = DateTime(current.year, current.month - 5, 1);
        final end = DateTime(current.year, current.month + 1, 0, 23, 59, 59);
        return (start, end);
      case TransactionPeriod.year:
        final start = DateTime(current.year, 1, 1);
        final end = DateTime(current.year, 12, 31, 23, 59, 59);
        return (start, end);
      case TransactionPeriod.customRange:
        final start = from != null ? DateTime(from!.year, from!.month, from!.day) : null;
        final end = to != null ? DateTime(to!.year, to!.month, to!.day, 23, 59, 59) : null;
        return (start, end);
    }
  }

  TransactionFilter copyWith({
    String? query,
    TransactionType? type,
    bool clearType = false,
    Category? category,
    bool clearCategory = false,
    TransactionPeriod? period,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    TransactionSort? sort,
    SortDirection? direction,
  }) => TransactionFilter(
    query: query ?? this.query,
    type: clearType ? null : type ?? this.type,
    category: clearCategory ? null : category ?? this.category,
    period: period ?? this.period,
    from: clearFrom ? null : from ?? this.from,
    to: clearTo ? null : to ?? this.to,
    sort: sort ?? this.sort,
    direction: direction ?? this.direction,
  );
}

List<FinanceTransaction> filterTransactions(
  List<FinanceTransaction> source,
  TransactionFilter filter, {
  DateTime? now,
}) {
  final query = filter.query.trim().toLowerCase();
  final (start, end) = filter.getEffectiveRange(now: now);

  final values = source.where((item) {
    final matchesQuery =
        query.isEmpty ||
        item.title.toLowerCase().contains(query) ||
        item.note.toLowerCase().contains(query);
    final matchesType = filter.type == null || item.type == filter.type;
    final matchesCategory =
        filter.category == null || item.category.id == filter.category!.id || item.category == filter.category;
    final matchesFrom = start == null || !item.date.isBefore(start);
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
