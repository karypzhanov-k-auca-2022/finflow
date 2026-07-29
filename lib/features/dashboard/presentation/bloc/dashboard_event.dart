part of 'dashboard_bloc.dart';

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

final class DashboardPeriodChanged extends DashboardEvent {
  const DashboardPeriodChanged({required this.period, this.from, this.to});

  final TransactionPeriod period;
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [period, from, to];
}
