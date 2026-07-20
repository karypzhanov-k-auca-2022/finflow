import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Проверьте подключение к интернету']);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Истекло время ожидания']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Сервис временно недоступен']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Не удалось загрузить локальные данные']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Что-то пошло не так. Попробуйте ещё раз',
  ]);
}
