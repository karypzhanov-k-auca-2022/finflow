import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/app/dependency_injection.dart';
import 'package:finflow/features/budgets/domain/entities/budget.dart';
import 'package:finflow/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:finflow/features/budgets/presentation/pages/budgets_page.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/categories/data/repositories/category_repository_impl.dart';
import 'package:finflow/features/categories/domain/usecases/category_use_cases.dart';
import 'package:finflow/features/transactions/domain/usecases/transaction_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers.dart';

class MockBudgetsBloc extends MockBloc<BudgetsEvent, BudgetsState>
    implements BudgetsBloc {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = MockTransactionRepository();
    if (!getIt.isRegistered<CategoryUseCases>()) {
      final catLocal = CategoryLocalDataSourceImpl(prefs);
      final catRepo = CategoryRepositoryImpl(local: catLocal);
      getIt.registerSingleton<CategoryUseCases>(CategoryUseCases(catRepo));
    }
    if (!getIt.isRegistered<TransactionUseCases>()) {
      getIt.registerSingleton<TransactionUseCases>(TransactionUseCases(repo));
    }
    stubLoad(repo, []);
  });

  testWidgets('tapping budget card opens budget drill-down details sheet', (tester) async {
    const budget = Budget(
      id: 'b1',
      categoryId: 'groceries',
      limit: 5000,
      spent: 2500,
      month: 7,
      year: 2026,
    );

    final bloc = MockBudgetsBloc();
    whenListen(
      bloc,
      const Stream<BudgetsState>.empty(),
      initialState: const BudgetsState(
        status: BudgetsStatus.success,
        budgets: [budget],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BudgetsBloc>.value(
          value: bloc,
          child: const BudgetsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);

    // Tap budget card to open drill-down sheet
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.text('Category Transactions'), findsOneWidget);
  });
}
