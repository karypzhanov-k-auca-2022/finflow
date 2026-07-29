import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/transaction_use_cases.dart';

part 'transactions_bloc.freezed.dart';
part 'transactions_event.dart';
part 'transactions_state.dart';

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
