import 'package:dio/dio.dart';
import 'package:finflow/core/error/failure.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finflow/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:finflow/features/transactions/data/models/transaction_model.dart';
import 'package:finflow/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finflow/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers.dart';

class MockLocal extends Mock implements TransactionLocalDataSource {}

class MockRemote extends Mock implements TransactionRemoteDataSource {}

void main() {
  late MockLocal local;
  late MockRemote remote;
  late TransactionRepositoryImpl repository;
  late TransactionModel model;

  setUpAll(() {
    registerFallbackValue(TransactionModel.fromEntity(transaction()));
  });
  setUp(() {
    local = MockLocal();
    remote = MockRemote();
    repository = TransactionRepositoryImpl(
      local: local,
      remote: remote,
      remoteEnabled: true,
    );
    model = TransactionModel.fromEntity(transaction());
  });

  test('gets local data when refresh is false', () async {
    when(() => local.getTransactions()).thenAnswer((_) async => [model]);
    final result = await repository.getTransactions();
    expect(result, isA<Success<TransactionsResult>>());
    verifyNever(() => remote.getTransactions());
  });

  test('saves transaction locally and remotely', () async {
    when(() => local.getTransactions()).thenAnswer((_) async => []);
    when(() => local.saveTransaction(any())).thenAnswer((_) async {});
    when(
      () => remote.saveTransaction(any(), isNew: any(named: 'isNew')),
    ).thenAnswer((_) async {});
    final result = await repository.saveTransaction(model);
    expect(result, isA<Success>());
    verify(() => local.saveTransaction(any())).called(1);
    verify(() => remote.saveTransaction(any(), isNew: true)).called(1);
  });

  test('returns cached data on remote error', () async {
    when(() => remote.getTransactions()).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/transactions')),
    );
    when(() => local.getTransactions()).thenAnswer((_) async => [model]);
    final result = await repository.getTransactions(refresh: true);
    expect(result.fold((_) => const [], (data) => data.transactions), [model]);
  });

  test('transforms local exception into CacheFailure', () async {
    when(() => local.getTransactions()).thenThrow(const FormatException());
    final result = await repository.getTransactions();
    expect(result, isA<Error>());
    expect((result as Error).failure, isA<CacheFailure>());
  });
}
