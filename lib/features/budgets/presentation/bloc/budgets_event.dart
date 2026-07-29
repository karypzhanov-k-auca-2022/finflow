part of 'budgets_bloc.dart';

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
