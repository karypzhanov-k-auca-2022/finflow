import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/usecases/calculate_analytics.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

final class AnalyticsRequested extends AnalyticsEvent {
  const AnalyticsRequested({this.months = 6});
  final int months;
  @override
  List<Object?> get props => [months];
}

enum AnalyticsStatus { initial, loading, success, empty, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.months = 6,
    this.data,
    this.failure,
  });
  final AnalyticsStatus status;
  final int months;
  final AnalyticsData? data;
  final Failure? failure;
  @override
  List<Object?> get props => [status, months, data, failure];
}

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc(this.useCases) : super(const AnalyticsState()) {
    on<AnalyticsRequested>(_load);

    _subscription = useCases.onTransactionsChanged.listen((_) {
      add(AnalyticsRequested(months: state.months));
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
    AnalyticsRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsState(status: AnalyticsStatus.loading, months: event.months));
    final result = await useCases.load();
    result.fold(
      (failure) => emit(
        AnalyticsState(
          status: AnalyticsStatus.failure,
          months: event.months,
          failure: failure,
        ),
      ),
      (data) => emit(
        AnalyticsState(
          status: data.transactions.isEmpty
              ? AnalyticsStatus.empty
              : AnalyticsStatus.success,
          months: event.months,
          data: calculateAnalytics(data.transactions, months: event.months),
        ),
      ),
    );
  }
}
