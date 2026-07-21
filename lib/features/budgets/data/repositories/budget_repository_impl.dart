import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/dio_failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../core/utils/logger_mixin.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl with LoggerMixin implements BudgetRepository {
  BudgetRepositoryImpl({
    required this.local,
    required this.remote,
    bool? remoteEnabled,
  }) : remoteEnabled = remoteEnabled ?? apiBaseUrl.isNotEmpty;
  final BudgetLocalDataSource local;
  final BudgetRemoteDataSource remote;
  final bool remoteEnabled;

  final _changeController = StreamController<void>.broadcast();

  @override
  Stream<void> get onBudgetsChanged => _changeController.stream;

  @override
  Future<Result<List<Budget>>> getBudgets({bool refresh = false}) async {
    logInfo('getBudgets (refresh: $refresh)');
    try {
      if (refresh && remoteEnabled) {
        try {
          final values = await remote.getBudgets();
          for (final value in values) {
            await local.saveBudget(value);
          }
          return Success(values);
        } on DioException catch (exception) {
          final cached = await local.getBudgets();
          return cached.isEmpty
              ? Error(mapDioException(exception))
              : Success(cached);
        }
      }
      return Success(await local.getBudgets());
    } catch (_) {
      return const Error(CacheFailure());
    }
  }

  @override
  Future<Result<Budget>> saveBudget(Budget budget) async {
    if (budget.limit <= 0) {
      return const Error(ValidationFailure('Limit must be greater than zero'));
    }
    try {
      final model = BudgetModel.fromEntity(budget);
      final isNew = !(await local.getBudgets()).any(
        (item) => item.id == budget.id,
      );
      await local.saveBudget(model);
      if (remoteEnabled) {
        try {
          await remote.saveBudget(model, isNew: isNew);
        } on DioException {
          /* Offline-first. */
        }
      }
      _changeController.add(null);
      return Success(budget);
    } catch (_) {
      return const Error(CacheFailure('Failed to save budget'));
    }
  }

  @override
  Future<Result<void>> deleteBudget(String id) async {
    try {
      await local.deleteBudget(id);
      if (remoteEnabled) {
        try {
          await remote.deleteBudget(id);
        } on DioException {
          /* Offline-first. */
        }
      }
      _changeController.add(null);
      return const Success(null);
    } catch (_) {
      return const Error(CacheFailure('Failed to delete budget'));
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await local.clear();
      _changeController.add(null);
      return const Success(null);
    } catch (_) {
      return const Error(CacheFailure());
    }
  }

  @override
  Future<Result<void>> reseed() async {
    try {
      await local.reseed();
      _changeController.add(null);
      return const Success(null);
    } catch (_) {
      return const Error(CacheFailure());
    }
  }
}
