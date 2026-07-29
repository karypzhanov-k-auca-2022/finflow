part of 'analytics_bloc.dart';

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
