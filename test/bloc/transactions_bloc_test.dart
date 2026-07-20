import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/core/error/failure.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/transactions/domain/entities/transaction.dart';
import 'package:finflow/features/transactions/domain/usecases/transaction_use_cases.dart';
import 'package:finflow/features/transactions/presentation/bloc/transaction_form_cubit.dart';
import 'package:finflow/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers.dart';

void main() {
  late MockTransactionRepository repository;
  late TransactionUseCases useCases;
  final item = transaction();

  setUpAll(() {
    registerFallbackValue(item);
  });
  setUp(() {
    repository = MockTransactionRepository();
    useCases = TransactionUseCases(repository);
  });

  blocTest<TransactionsBloc, TransactionsState>(
    'успешная загрузка',
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
    'empty state',
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
    'ошибка загрузки',
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
    'удаление транзакции',
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
    'изменение фильтра',
    seed: () => TransactionsState(
      status: TransactionsStatus.success,
      all: [
        item,
        transaction(id: '2', title: 'Такси', category: AppCategory.transport),
      ],
      visible: [item],
    ),
    build: () => TransactionsBloc(useCases),
    act: (bloc) => bloc.add(
      const TransactionFilterChanged(
        TransactionFilter(category: AppCategory.transport),
      ),
    ),
    expect: () => [
      isA<TransactionsState>().having((s) => s.visible.single.id, 'id', '2'),
    ],
  );

  blocTest<TransactionFormCubit, TransactionFormState>(
    'создание транзакции',
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
