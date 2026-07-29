part of 'budgets_bloc.dart';

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
