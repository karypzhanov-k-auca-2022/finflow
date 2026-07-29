import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../budgets/domain/usecases/budget_use_cases.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/build_dashboard.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this.transactions, this.budgets)
    : super(const DashboardState()) {
    on<DashboardRequested>(_onRequested);
    on<DashboardPeriodChanged>(_onPeriodChanged);

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
    emit(state.copyWith(status: DashboardStatus.loading));
    await _loadAndEmit(event.refresh, emit);
  }

  Future<void> _onPeriodChanged(
    DashboardPeriodChanged event,
    Emitter<DashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        period: event.period,
        from: event.from,
        to: event.to,
      ),
    );
    await _loadAndEmit(false, emit);
  }

  Future<void> _loadAndEmit(bool refresh, Emitter<DashboardState> emit) async {
    final transactionResult = await transactions.load(refresh: refresh);
    await transactionResult.fold(
      (failure) async => emit(
        state.copyWith(status: DashboardStatus.failure, failure: failure),
      ),
      (data) async {
        final values = data.transactions;
        final budgetResult = await budgets.load(refresh: refresh);
        budgetResult.fold(
          (failure) => emit(
            state.copyWith(status: DashboardStatus.failure, failure: failure),
          ),
          (budgetValues) {
            final dashboardData = buildDashboardData(
              values,
              budgetValues,
              period: state.period,
              from: state.from,
              to: state.to,
            );
            emit(
              state.copyWith(
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
