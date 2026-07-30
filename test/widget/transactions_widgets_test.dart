import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/app/dependency_injection.dart';
import 'package:finflow/core/error/failure.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/categories/data/repositories/category_repository_impl.dart';
import 'package:finflow/features/categories/domain/usecases/category_use_cases.dart';
import 'package:finflow/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:finflow/features/transactions/domain/entities/transaction.dart';
import 'package:finflow/features/transactions/domain/usecases/transaction_use_cases.dart';
import 'package:finflow/features/transactions/presentation/transaction_form/cubit/transaction_form_cubit.dart';
import 'package:finflow/features/transactions/presentation/transaction_form/pages/transaction_form_page.dart';
import 'package:finflow/features/transactions/presentation/transactions_list/bloc/transactions_bloc.dart';
import 'package:finflow/features/transactions/presentation/transactions_list/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers.dart';

class MockTransactionsBloc
    extends MockBloc<TransactionsEvent, TransactionsState>
    implements TransactionsBloc {}

class MockCategoriesBloc extends MockBloc<CategoriesEvent, CategoriesState>
    implements CategoriesBloc {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await initializeDateFormatting('en_US');
    registerFallbackValue(const TransactionsRequested());
    if (!getIt.isRegistered<CategoryUseCases>()) {
      final catLocal = CategoryLocalDataSourceImpl(prefs);
      final catRepo = CategoryRepositoryImpl(local: catLocal);
      getIt.registerSingleton<CategoryUseCases>(CategoryUseCases(catRepo));
    }
  });

  testWidgets('displays loading progress indicator', (tester) async {
    final bloc = _bloc(
      const TransactionsState(status: TransactionsStatus.loading),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays empty state widget when no transactions', (
    tester,
  ) async {
    final bloc = _bloc(
      const TransactionsState(status: TransactionsStatus.empty),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.text('No transactions'), findsOneWidget);
  });

  testWidgets('displays transaction list items', (tester) async {
    final item = transaction(title: 'Supermarket Purchase');
    final bloc = _bloc(
      TransactionsState(
        status: TransactionsStatus.success,
        all: [item],
        visible: [item],
      ),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.text('Supermarket Purchase'), findsOneWidget);
  });

  testWidgets('search field filters the rendered transaction list', (
    tester,
  ) async {
    final repository = MockTransactionRepository();
    final groceries = transaction(id: 'groceries', title: 'Weekly groceries');
    final salary = transaction(
      id: 'salary',
      title: 'July Salary',
      type: TransactionType.income,
      category: testSalaryCategory,
    );
    stubLoad(repository, [groceries, salary]);
    final bloc = TransactionsBloc(TransactionUseCases(repository))
      ..add(const TransactionsRequested());
    addTearDown(bloc.close);

    await tester.pumpWidget(_transactionsApp(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Weekly groceries'), findsOneWidget);
    expect(find.text('July Salary'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'salary');
    await tester.pumpAndSettle();

    expect(find.text('Weekly groceries'), findsNothing);
    expect(find.text('July Salary'), findsOneWidget);
  });

  testWidgets('error state contains Retry button and dispatches reload event', (
    tester,
  ) async {
    final bloc = _bloc(
      const TransactionsState(
        status: TransactionsStatus.failure,
        failure: CacheFailure(),
      ),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    verify(() => bloc.add(any(that: isA<TransactionsRequested>()))).called(1);
  });

  testWidgets('form displays validation errors when fields are empty', (
    tester,
  ) async {
    final repository = MockTransactionRepository();
    final cubit = TransactionFormCubit(TransactionUseCases(repository));
    final catBloc = _catBloc();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TransactionFormCubit>.value(value: cubit),
            BlocProvider<CategoriesBloc>.value(value: catBloc),
          ],
          child: const TransactionFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter title'), findsOneWidget);
    expect(find.text('Enter a positive amount'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('form keeps entered values when viewport rotates', (
    tester,
  ) async {
    final repository = MockTransactionRepository();
    final cubit = TransactionFormCubit(TransactionUseCases(repository));
    final catBloc = _catBloc();
    addTearDown(() async {
      await cubit.close();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.binding.setSurfaceSize(const Size(800, 360));
    await tester.pumpWidget(
      MaterialApp(
        restorationScopeId: 'test',
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TransactionFormCubit>.value(value: cubit),
            BlocProvider<CategoriesBloc>.value(value: catBloc),
          ],
          child: const TransactionFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Rotation-safe draft',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '1250',
    );

    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpAndSettle();

    expect(find.text('Rotation-safe draft'), findsOneWidget);
    expect(find.text('1250'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('form restores draft after state restoration', (tester) async {
    final repository = MockTransactionRepository();
    final cubit = TransactionFormCubit(TransactionUseCases(repository));
    final catBloc = _catBloc();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        restorationScopeId: 'test',
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TransactionFormCubit>.value(value: cubit),
            BlocProvider<CategoriesBloc>.value(value: catBloc),
          ],
          child: const TransactionFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Restored draft',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '900');
    await tester.pump();

    await tester.restartAndRestore();
    await tester.pumpAndSettle();

    final restoredTitle = tester.widget<TextFormField>(
      find.byKey(const Key('transaction_title_field')),
    );
    final restoredAmount = tester.widget<TextFormField>(
      find.byKey(const Key('transaction_amount_field')),
    );
    expect(restoredTitle.controller?.text, 'Restored draft');
    expect(restoredAmount.controller?.text, '900');
  });
}

MockTransactionsBloc _bloc(TransactionsState state) {
  final bloc = MockTransactionsBloc();
  whenListen(
    bloc,
    const Stream<TransactionsState>.empty(),
    initialState: state,
  );
  return bloc;
}

MockCategoriesBloc _catBloc() {
  final bloc = MockCategoriesBloc();
  whenListen(
    bloc,
    const Stream<CategoriesState>.empty(),
    initialState: const CategoriesState(
      status: CategoriesStatus.success,
      categories: defaultCategoryModels,
    ),
  );
  return bloc;
}

Widget _transactionsApp(TransactionsBloc bloc) => MaterialApp(
  home: MultiBlocProvider(
    providers: [
      BlocProvider<TransactionsBloc>.value(value: bloc),
      BlocProvider<CategoriesBloc>.value(value: _catBloc()),
    ],
    child: const TransactionsPage(),
  ),
);
