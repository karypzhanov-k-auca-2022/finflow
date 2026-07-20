import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_use_cases.dart';

part 'transactions_bloc.freezed.dart';

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

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this.useCases) : super(const TransactionsState()) {
    on<TransactionsRequested>(_load);
    on<TransactionDeleteRequested>(_delete);
    on<TransactionFilterChanged>(_filter);

    _subscription = useCases.onTransactionsChanged.listen((_) {
      add(const TransactionsRequested());
    });
  }
  final TransactionUseCases useCases;
  late final StreamSubscription<void> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  Future<void> _load(
    TransactionsRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    final result = await useCases.load(refresh: event.refresh);
    result.fold(
      (failure) => emit(
        TransactionsState(
          status: TransactionsStatus.failure,
          filter: state.filter,
          failure: failure,
        ),
      ),
      (data) {
        final values = data.transactions;
        final visible = filterTransactions(values, state.filter);
        emit(
          TransactionsState(
            status: values.isEmpty
                ? TransactionsStatus.empty
                : TransactionsStatus.success,
            all: values,
            visible: visible,
            filter: state.filter,
          ),
        );
      },
    );
  }

  Future<void> _delete(
    TransactionDeleteRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    final result = await useCases.delete(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(status: TransactionsStatus.failure, failure: failure),
      ),
      (_) {
        final all = state.all.where((item) => item.id != event.id).toList();
        emit(
          state.copyWith(
            status: all.isEmpty
                ? TransactionsStatus.empty
                : TransactionsStatus.success,
            all: all,
            visible: filterTransactions(all, state.filter),
          ),
        );
      },
    );
  }

  void _filter(
    TransactionFilterChanged event,
    Emitter<TransactionsState> emit,
  ) {
    emit(
      state.copyWith(
        filter: event.filter,
        visible: filterTransactions(state.all, event.filter),
      ),
    );
  }
}
