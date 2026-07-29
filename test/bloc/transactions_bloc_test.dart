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
