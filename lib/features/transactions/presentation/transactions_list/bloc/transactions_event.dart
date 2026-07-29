part of 'transactions_bloc.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

final class TransactionsRequested extends TransactionsEvent {
  const TransactionsRequested({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

final class TransactionDeleteRequested extends TransactionsEvent {
  const TransactionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class TransactionFilterChanged extends TransactionsEvent {
  const TransactionFilterChanged(this.filter);

  final TransactionFilter filter;

  @override
  List<Object?> get props => [
    filter.query,
    filter.type,
    filter.category,
    filter.from,
    filter.to,
    filter.sort,
    filter.direction,
  ];
}
