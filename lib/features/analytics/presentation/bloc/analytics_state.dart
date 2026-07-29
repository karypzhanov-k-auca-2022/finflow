part of 'analytics_bloc.dart';

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
