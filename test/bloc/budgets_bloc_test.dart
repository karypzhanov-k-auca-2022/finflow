import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/core/error/failure.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/budgets/domain/entities/budget.dart';
import 'package:finflow/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finflow/features/budgets/domain/usecases/budget_use_cases.dart';
import 'package:finflow/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:finflow/features/transactions/domain/usecases/transaction_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {
  @override
  Stream<void> get onBudgetsChanged => const Stream<void>.empty();
}

void main() {
  late MockBudgetRepository budgetRepository;
  late MockTransactionRepository transactionRepository;
  late BudgetUseCases budgetUseCases;
  late TransactionUseCases transactionUseCases;

  const testBudget = Budget(
    id: 'b1',
    categoryId: 'groceries',
    limit: 50000,
    spent: 0,
    month: 7,
    year: 2026,
  );

  setUp(() {
    budgetRepository = MockBudgetRepository();
    transactionRepository = MockTransactionRepository();
    budgetUseCases = BudgetUseCases(budgetRepository);
    transactionUseCases = TransactionUseCases(transactionRepository);
  });

  blocTest<BudgetsBloc, BudgetsState>(
    'emits [loading, empty] when budget list is empty',
    build: () {
      when(
        () => budgetRepository.getBudgets(refresh: any(named: 'refresh')),
      ).thenAnswer((_) async => const Success([]));
      stubLoad(transactionRepository, []);
      return BudgetsBloc(budgetUseCases, transactionUseCases);
    },
    act: (bloc) => bloc.add(const BudgetsRequested()),
    expect: () => [
      const BudgetsState(status: BudgetsStatus.loading),
      const BudgetsState(status: BudgetsStatus.empty, budgets: []),
    ],
  );

  blocTest<BudgetsBloc, BudgetsState>(
    'emits [loading, success] with calculated spent amount for budgets',
    build: () {
      when(
        () => budgetRepository.getBudgets(refresh: any(named: 'refresh')),
      ).thenAnswer((_) async => const Success([testBudget]));
      final tx = transaction(amount: 15000);
      stubLoad(transactionRepository, [tx]);
      return BudgetsBloc(budgetUseCases, transactionUseCases);
    },
    act: (bloc) => bloc.add(const BudgetsRequested()),
    expect: () => [
      const BudgetsState(status: BudgetsStatus.loading),
      isA<BudgetsState>()
          .having((s) => s.status, 'status', BudgetsStatus.success)
          .having((s) => s.budgets.first.spent, 'spent', 15000),
    ],
  );

  blocTest<BudgetsBloc, BudgetsState>(
    'emits [loading, failure] on budget repository error',
    build: () {
      when(
        () => budgetRepository.getBudgets(refresh: any(named: 'refresh')),
      ).thenAnswer((_) async => const Error(CacheFailure('Failed to load budgets')));
      stubLoad(transactionRepository, []);
      return BudgetsBloc(budgetUseCases, transactionUseCases);
    },
    act: (bloc) => bloc.add(const BudgetsRequested()),
    expect: () => [
      const BudgetsState(status: BudgetsStatus.loading),
      isA<BudgetsState>()
          .having((s) => s.status, 'status', BudgetsStatus.failure)
          .having((s) => s.failure, 'failure', isA<CacheFailure>()),
    ],
  );
}
