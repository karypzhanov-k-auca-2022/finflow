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
    when(() => local.getTransactions(any())).thenAnswer((_) async => [model]);
    final result = await repository.getTransactions();
    expect(result, isA<Success<TransactionsResult>>());
    verifyNever(() => remote.getTransactions());
  });

  test('refresh replaces local cache with remote snapshot', () async {
    final remoteModel = TransactionModel.fromEntity(
      transaction(id: 'remote', title: 'Remote value'),
    );
    when(() => remote.getTransactions()).thenAnswer((_) async => [remoteModel]);
    when(
      () => local.replaceTransactions(any(), any()),
    ).thenAnswer((_) async {});

    final result = await repository.getTransactions(refresh: true);

    expect(result.fold((_) => null, (data) => data.fromCache), isFalse);
    expect(result.fold((_) => const [], (data) => data.transactions), [
      remoteModel,
    ]);
    verify(() => local.replaceTransactions([remoteModel], 'guest')).called(1);
    verifyNever(() => local.saveTransaction(any(), any()));
  });

  test('saves transaction locally and remotely', () async {
    when(() => local.getTransactions(any())).thenAnswer((_) async => []);
    when(() => local.saveTransaction(any(), any())).thenAnswer((_) async {});
    when(
      () => remote.saveTransaction(any(), isNew: any(named: 'isNew')),
    ).thenAnswer((_) async {});
    final result = await repository.saveTransaction(model);
    expect(result, isA<Success>());
    verify(() => local.saveTransaction(any(), any())).called(1);
    verify(() => remote.saveTransaction(any(), isNew: true)).called(1);
  });

  test('updates existing remote transaction with isNew false', () async {
    when(() => local.getTransactions(any())).thenAnswer((_) async => [model]);
    when(() => local.saveTransaction(any(), any())).thenAnswer((_) async {});
    when(
      () => remote.saveTransaction(any(), isNew: any(named: 'isNew')),
    ).thenAnswer((_) async {});

    final result = await repository.saveTransaction(model);

    expect(result, isA<Success>());
    verify(() => remote.saveTransaction(any(), isNew: false)).called(1);
  });

  test('rejects invalid transaction before accessing data sources', () async {
    final emptyTitle = model.copyWith(title: '  ');
    final invalidAmount = model.copyWith(amount: -1);

    final titleResult = await repository.saveTransaction(emptyTitle);
    final amountResult = await repository.saveTransaction(invalidAmount);

    expect((titleResult as Error).failure, isA<ValidationFailure>());
    expect((amountResult as Error).failure, isA<ValidationFailure>());
    verifyNever(() => local.getTransactions(any()));
    verifyNever(() => local.saveTransaction(any(), any()));
    verifyNever(
      () => remote.saveTransaction(any(), isNew: any(named: 'isNew')),
    );
  });

  test('returns cached data on remote error', () async {
    when(() => remote.getTransactions()).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/transactions')),
    );
    when(() => local.getTransactions(any())).thenAnswer((_) async => [model]);
    final result = await repository.getTransactions(refresh: true);
    expect(result.fold((_) => const [], (data) => data.transactions), [model]);
  });

  test('saves locally when network is unavailable', () async {
    when(() => local.getTransactions(any())).thenAnswer((_) async => []);
    when(() => local.saveTransaction(any(), any())).thenAnswer((_) async {});
    when(
      () => remote.saveTransaction(any(), isNew: any(named: 'isNew')),
    ).thenThrow(
      DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/transactions'),
      ),
    );

    final result = await repository.saveTransaction(model);

    expect(result, isA<Success>());
    verify(() => local.saveTransaction(any(), any())).called(1);
  });

  test('delete succeeds locally when remote is unavailable', () async {
    when(
      () => local.deleteTransaction(model.id, any()),
    ).thenAnswer((_) async {});
    when(() => remote.deleteTransaction(model.id)).thenThrow(
      DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/transactions/${model.id}'),
      ),
    );

    final result = await repository.deleteTransaction(model.id);

    expect(result, isA<Success<void>>());
    verify(() => local.deleteTransaction(model.id, 'guest')).called(1);
    verify(() => remote.deleteTransaction(model.id)).called(1);
  });

  test('save, delete, clear, and reseed emit change notifications', () async {
    when(() => local.getTransactions(any())).thenAnswer((_) async => []);
    when(() => local.saveTransaction(any(), any())).thenAnswer((_) async {});
    when(
      () => remote.saveTransaction(any(), isNew: any(named: 'isNew')),
    ).thenAnswer((_) async {});
    when(() => local.deleteTransaction(any(), any())).thenAnswer((_) async {});
    when(() => remote.deleteTransaction(any())).thenAnswer((_) async {});
    when(() => local.clear(any())).thenAnswer((_) async {});
    when(() => local.reseed(any())).thenAnswer((_) async {});

    var eventCount = 0;
    final subscription = repository.onTransactionsChanged.listen(
      (_) => eventCount++,
    );
    addTearDown(subscription.cancel);

    await repository.saveTransaction(model);
    await repository.deleteTransaction(model.id);
    await repository.clear();
    await repository.reseed();
    await Future<void>.delayed(Duration.zero);

    expect(eventCount, 4);
  });

  test('clear and reseed delegate to local storage for current user', () async {
    when(() => local.clear(any())).thenAnswer((_) async {});
    when(() => local.reseed(any())).thenAnswer((_) async {});

    expect(await repository.clear(), isA<Success<void>>());
    expect(await repository.reseed(), isA<Success<void>>());

    verify(() => local.clear('guest')).called(1);
    verify(() => local.reseed('guest')).called(1);
  });

  test('local delete error is returned as CacheFailure', () async {
    when(
      () => local.deleteTransaction(any(), any()),
    ).thenThrow(const FormatException());

    final result = await repository.deleteTransaction(model.id);

    expect(result, isA<Error<void>>());
    expect((result as Error<void>).failure, isA<CacheFailure>());
    verifyNever(() => remote.deleteTransaction(any()));
  });

  test('transforms local exception into CacheFailure', () async {
    when(() => local.getTransactions(any())).thenThrow(const FormatException());
    final result = await repository.getTransactions();
    expect(result, isA<Error>());
    expect((result as Error).failure, isA<CacheFailure>());
  });
}
