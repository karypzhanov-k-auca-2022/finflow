part of 'transactions_bloc.dart';

enum TransactionsStatus { initial, loading, success, empty, failure }

@freezed
abstract class TransactionsState with _$TransactionsState {
  const factory TransactionsState({
    @Default(TransactionsStatus.initial) TransactionsStatus status,
    @Default([]) List<FinanceTransaction> all,
    @Default([]) List<FinanceTransaction> visible,
    @Default(TransactionFilter()) TransactionFilter filter,
    Failure? failure,
  }) = _TransactionsState;
}
