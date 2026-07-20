import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../budgets/domain/usecases/budget_use_cases.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/build_dashboard.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

final class DashboardRequested extends DashboardEvent {
  const DashboardRequested({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => [refresh];
}

enum DashboardStatus { initial, loading, success, empty, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.data,
    this.failure,
  });
  final DashboardStatus status;
  final DashboardData? data;
  final Failure? failure;
  @override
  List<Object?> get props => [status, data, failure];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this.transactions, this.budgets)
    : super(const DashboardState()) {
    on<DashboardRequested>(_onRequested);

    _transactionsSubscription = transactions.onTransactionsChanged.listen((_) {
      add(const DashboardRequested());
    });
    _budgetsSubscription = budgets.onBudgetsChanged.listen((_) {
      add(const DashboardRequested());
    });
  }
  final TransactionUseCases transactions;
  final BudgetUseCases budgets;
  late final StreamSubscription<void> _transactionsSubscription;
  late final StreamSubscription<void> _budgetsSubscription;

  @override
  Future<void> close() {
    _transactionsSubscription.cancel();
    _budgetsSubscription.cancel();
    return super.close();
  }

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardState(status: DashboardStatus.loading));
    final transactionResult = await transactions.load(refresh: event.refresh);
    await transactionResult.fold(
      (failure) async => emit(
        DashboardState(status: DashboardStatus.failure, failure: failure),
      ),
      (data) async {
        final values = data.transactions;
        final budgetResult = await budgets.load(refresh: event.refresh);
        budgetResult.fold(
          (failure) => emit(
            DashboardState(status: DashboardStatus.failure, failure: failure),
          ),
          (budgetValues) {
            final dashboardData = buildDashboardData(values, budgetValues);
            emit(
              DashboardState(
                status: values.isEmpty
                    ? DashboardStatus.empty
                    : DashboardStatus.success,
                data: dashboardData,
              ),
            );
          },
        );
      },
    );
  }
}
