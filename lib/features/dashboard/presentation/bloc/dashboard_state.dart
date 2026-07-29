part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, success, empty, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.data,
    this.failure,
    this.period = TransactionPeriod.month,
    this.from,
    this.to,
  });

  final DashboardStatus status;
  final DashboardData? data;
  final Failure? failure;
  final TransactionPeriod period;
  final DateTime? from;
  final DateTime? to;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    Failure? failure,
    TransactionPeriod? period,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
  }) => DashboardState(
    status: status ?? this.status,
    data: data ?? this.data,
    failure: failure ?? this.failure,
    period: period ?? this.period,
    from: clearFrom ? null : from ?? this.from,
    to: clearTo ? null : to ?? this.to,
  );

  @override
  List<Object?> get props => [status, data, failure, period, from, to];
}
