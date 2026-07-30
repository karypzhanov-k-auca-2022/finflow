import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/core/error/failure.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/transactions/domain/usecases/transaction_use_cases.dart';
import 'package:finflow/features/transactions/presentation/transaction_form/cubit/transaction_form_cubit.dart';
import 'package:finflow/features/transactions/presentation/transactions_list/bloc/transactions_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers.dart';

void main() {
  late MockTransactionRepository repository;
  late TransactionUseCases useCases;
  final item = transaction();
  final transportCategory = defaultCategoryModels.firstWhere(
    (c) => c.id == 'transport',
  );

  setUpAll(() {
    registerFallbackValue(item);
  });

  setUp(() {
    repository = MockTransactionRepository();
    useCases = TransactionUseCases(repository);
  });

  blocTest<TransactionsBloc, TransactionsState>(
    'successful load of transactions',
    build: () {
      stubLoad(repository, [item]);
      return TransactionsBloc(useCases);
    },
    act: (bloc) => bloc.add(const TransactionsRequested()),
    expect: () => [
      isA<TransactionsState>().having(
        (s) => s.status,
        'status',
        TransactionsStatus.loading,
      ),
      isA<TransactionsState>()
          .having((s) => s.status, 'status', TransactionsStatus.success)
          .having((s) => s.visible, 'visible', [item]),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'passes refresh flag to repository',
    build: () {
      stubLoad(repository, [item]);
      return TransactionsBloc(useCases);
    },
    act: (bloc) => bloc.add(const TransactionsRequested(refresh: true)),
    expect: () => [
      isA<TransactionsState>().having(
        (state) => state.status,
        'status',
        TransactionsStatus.loading,
      ),
      isA<TransactionsState>().having(
        (state) => state.status,
        'status',
        TransactionsStatus.success,
      ),
    ],
    verify: (_) {
      verify(() => repository.getTransactions(refresh: true)).called(1);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'emits empty status when list is empty',
    build: () {
      stubLoad(repository, []);
      return TransactionsBloc(useCases);
    },
    act: (bloc) => bloc.add(const TransactionsRequested()),
    expect: () => [
      isA<TransactionsState>().having(
        (s) => s.status,
        'status',
        TransactionsStatus.loading,
      ),
      isA<TransactionsState>().having(
        (s) => s.status,
        'status',
        TransactionsStatus.empty,
      ),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'emits failure status on repository error',
    build: () {
      when(
        () => repository.getTransactions(refresh: any(named: 'refresh')),
      ).thenAnswer((_) async => const Error(CacheFailure()));
      return TransactionsBloc(useCases);
    },
    act: (bloc) => bloc.add(const TransactionsRequested()),
    expect: () => [
      isA<TransactionsState>().having(
        (s) => s.status,
        'status',
        TransactionsStatus.loading,
      ),
      isA<TransactionsState>().having(
        (s) => s.status,
        'status',
        TransactionsStatus.failure,
      ),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'handles transaction deletion',
    seed: () => TransactionsState(
      status: TransactionsStatus.success,
      all: [item],
      visible: [item],
    ),
    build: () {
      when(
        () => repository.deleteTransaction(item.id),
      ).thenAnswer((_) async => const Success(null));
      return TransactionsBloc(useCases);
    },
    act: (bloc) => bloc.add(TransactionDeleteRequested(item.id)),
    expect: () => [
      isA<TransactionsState>()
          .having((s) => s.status, 'status', TransactionsStatus.empty)
          .having((s) => s.all, 'all', isEmpty),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'keeps transactions and emits failure when deletion fails',
    seed: () => TransactionsState(
      status: TransactionsStatus.success,
      all: [item],
      visible: [item],
    ),
    build: () {
      when(
        () => repository.deleteTransaction(item.id),
      ).thenAnswer((_) async => const Error(CacheFailure()));
      return TransactionsBloc(useCases);
    },
    act: (bloc) => bloc.add(TransactionDeleteRequested(item.id)),
    expect: () => [
      isA<TransactionsState>()
          .having((state) => state.status, 'status', TransactionsStatus.failure)
          .having((state) => state.all, 'all', [item])
          .having((state) => state.visible, 'visible', [item]),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'preserves and reapplies active filter after reload',
    seed: () => TransactionsState(
      status: TransactionsStatus.success,
      filter: const TransactionFilter(query: 'taxi'),
      all: [item],
      visible: const [],
    ),
    build: () {
      stubLoad(repository, [item, transaction(id: '2', title: 'Airport Taxi')]);
      return TransactionsBloc(useCases);
    },
    act: (bloc) => bloc.add(const TransactionsRequested()),
    expect: () => [
      isA<TransactionsState>()
          .having((state) => state.status, 'status', TransactionsStatus.loading)
          .having((state) => state.filter.query, 'query', 'taxi'),
      isA<TransactionsState>()
          .having((state) => state.status, 'status', TransactionsStatus.success)
          .having((state) => state.filter.query, 'query', 'taxi')
          .having(
            (state) => state.visible.map((value) => value.id),
            'visible ids',
            ['2'],
          ),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'applies category filter update',
    seed: () => TransactionsState(
      status: TransactionsStatus.success,
      all: [
        item,
        transaction(id: '2', title: 'Taxi', category: transportCategory),
      ],
      visible: [item],
    ),
    build: () => TransactionsBloc(useCases),
    act: (bloc) => bloc.add(
      TransactionFilterChanged(TransactionFilter(category: transportCategory)),
    ),
    expect: () => [
      isA<TransactionsState>().having((s) => s.visible.single.id, 'id', '2'),
    ],
  );

  blocTest<TransactionFormCubit, TransactionFormState>(
    'submits transaction successfully',
    build: () {
      when(
        () => repository.saveTransaction(any()),
      ).thenAnswer((_) async => Success(item));
      return TransactionFormCubit(useCases);
    },
    act: (cubit) => cubit.submit(item),
    expect: () => [
      const TransactionFormState(status: FormStatus.saving),
      const TransactionFormState(status: FormStatus.success),
    ],
  );
}
