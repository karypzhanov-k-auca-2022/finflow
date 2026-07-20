import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/budget_use_cases.dart';

sealed class BudgetsEvent extends Equatable {
  const BudgetsEvent();
  @override
  List<Object?> get props => [];
}

final class BudgetsRequested extends BudgetsEvent {
  const BudgetsRequested({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => [refresh];
}

final class BudgetSaved extends BudgetsEvent {
  const BudgetSaved(this.budget);
  final Budget budget;
  @override
  List<Object?> get props => [budget];
}

final class BudgetDeleted extends BudgetsEvent {
  const BudgetDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

enum BudgetsStatus { initial, loading, success, empty, failure }

class BudgetsState extends Equatable {
  const BudgetsState({
    this.status = BudgetsStatus.initial,
    this.budgets = const [],
    this.failure,
  });
  final BudgetsStatus status;
  final List<Budget> budgets;
  final Failure? failure;
  @override
  List<Object?> get props => [status, budgets, failure];
}

class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  BudgetsBloc(this.budgetUseCases, this.transactionUseCases)
    : super(const BudgetsState()) {
    on<BudgetsRequested>(_load);
    on<BudgetSaved>(_save);
    on<BudgetDeleted>(_delete);

    _transactionsSubscription = transactionUseCases.onTransactionsChanged.listen((_) {
      add(const BudgetsRequested());
    });
    _budgetsSubscription = budgetUseCases.onBudgetsChanged.listen((_) {
      add(const BudgetsRequested());
    });
  }
  final BudgetUseCases budgetUseCases;
  final TransactionUseCases transactionUseCases;
  late final StreamSubscription<void> _transactionsSubscription;
  late final StreamSubscription<void> _budgetsSubscription;

  @override
  Future<void> close() {
    _transactionsSubscription.cancel();
    _budgetsSubscription.cancel();
    return super.close();
  }

  Future<void> _load(BudgetsRequested event, Emitter<BudgetsState> emit) async {
    emit(const BudgetsState(status: BudgetsStatus.loading));
    final budgets = await budgetUseCases.load(refresh: event.refresh);
    final transactions = await transactionUseCases.load(refresh: event.refresh);
    budgets.fold(
      (failure) =>
          emit(BudgetsState(status: BudgetsStatus.failure, failure: failure)),
      (budgetValues) => transactions.fold(
        (failure) =>
            emit(BudgetsState(status: BudgetsStatus.failure, failure: failure)),
        (data) {
          final values = budgetUseCases.withSpent(
            budgetValues,
            data.transactions,
          );
          emit(
            BudgetsState(
              status: values.isEmpty
                  ? BudgetsStatus.empty
                  : BudgetsStatus.success,
              budgets: values,
            ),
          );
        },
      ),
    );
  }

  Future<void> _save(BudgetSaved event, Emitter<BudgetsState> emit) async {
    final result = await budgetUseCases.save(event.budget);
    result.fold(
      (failure) => emit(
        BudgetsState(
          status: BudgetsStatus.failure,
          budgets: state.budgets,
          failure: failure,
        ),
      ),
      (_) => add(const BudgetsRequested()),
    );
  }

  Future<void> _delete(BudgetDeleted event, Emitter<BudgetsState> emit) async {
    final result = await budgetUseCases.delete(event.id);
    result.fold(
      (failure) => emit(
        BudgetsState(
          status: BudgetsStatus.failure,
          budgets: state.budgets,
          failure: failure,
        ),
      ),
      (_) => add(const BudgetsRequested()),
    );
  }
}
