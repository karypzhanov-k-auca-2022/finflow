import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/dio_failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../core/utils/logger_mixin.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl with LoggerMixin implements TransactionRepository {
  TransactionRepositoryImpl({
    required this.local,
    required this.remote,
    FirebaseAuth? auth,
    bool? remoteEnabled,
  })  : _auth = auth,
        remoteEnabled = remoteEnabled ?? apiBaseUrl.isNotEmpty;

  final TransactionLocalDataSource local;
  final TransactionRemoteDataSource remote;
  final FirebaseAuth? _auth;
  final bool remoteEnabled;

  final _changeController = StreamController<void>.broadcast();

  String get _userId {
    try {
      final instance = _auth ?? FirebaseAuth.instance;
      return instance.currentUser?.uid ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  @override
  Stream<void> get onTransactionsChanged => _changeController.stream;

  @override
  Future<Result<TransactionsResult>> getTransactions({
    bool refresh = false,
  }) async {
    logInfo('getTransactions for user $_userId (refresh: $refresh)');
    try {
      if (refresh && remoteEnabled) {
        try {
          final remoteValues = await remote.getTransactions();
          for (final value in remoteValues) {
            await local.saveTransaction(value, _userId);
          }
          logInfo('Loaded ${remoteValues.length} transactions from remote');
          return Success((transactions: remoteValues, fromCache: false));
        } on DioException catch (exception) {
          logError('Remote getTransactions failed, falling back to cache', exception);
          final cached = await local.getTransactions(_userId);
          return cached.isEmpty
              ? Error(mapDioException(exception))
              : Success((transactions: cached, fromCache: true));
        }
      }
      final cached = await local.getTransactions(_userId);
      logInfo('Loaded ${cached.length} transactions from local cache for user $_userId');
      return Success((transactions: cached, fromCache: true));
    } catch (e, stack) {
      logError('Failed to get transactions', e, stack);
      return const Error(CacheFailure());
    }
  }

  @override
  Future<Result<FinanceTransaction>> saveTransaction(
    FinanceTransaction transaction,
  ) async {
    if (transaction.title.trim().isEmpty || transaction.amount <= 0) {
      return const Error(ValidationFailure('Check title and amount'));
    }
    try {
      final model = TransactionModel.fromEntity(transaction);
      final isNew = !(await local.getTransactions(_userId)).any(
        (item) => item.id == transaction.id,
      );
      await local.saveTransaction(model, _userId);
      if (remoteEnabled) {
        try {
          await remote.saveTransaction(model, isNew: isNew);
        } on DioException {
          // Offline fallback
        }
      }
      _changeController.add(null);
      return Success(transaction);
    } catch (_) {
      return const Error(CacheFailure('Failed to save transaction'));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      await local.deleteTransaction(id, _userId);
      if (remoteEnabled) {
        try {
          await remote.deleteTransaction(id);
        } on DioException {
          // Offline fallback
        }
      }
      _changeController.add(null);
      return const Success(null);
    } catch (_) {
      return const Error(CacheFailure('Failed to delete transaction'));
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await local.clear(_userId);
      _changeController.add(null);
      return const Success(null);
    } catch (_) {
      return const Error(CacheFailure());
    }
  }

  @override
  Future<Result<void>> reseed() async {
    try {
      await local.reseed(_userId);
      _changeController.add(null);
      return const Success(null);
    } catch (_) {
      return const Error(CacheFailure());
    }
  }
}
