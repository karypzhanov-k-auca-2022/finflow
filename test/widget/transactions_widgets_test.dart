import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/app/dependency_injection.dart';
import 'package:finflow/core/error/failure.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/categories/data/repositories/category_repository_impl.dart';
import 'package:finflow/features/categories/domain/usecases/category_use_cases.dart';
import 'package:finflow/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:finflow/features/transactions/domain/usecases/transaction_use_cases.dart';
import 'package:finflow/features/transactions/presentation/bloc/transaction_form_cubit.dart';
import 'package:finflow/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:finflow/features/transactions/presentation/pages/transaction_form_page.dart';
import 'package:finflow/features/transactions/presentation/pages/transactions_page.dart';
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

class MockCategoriesBloc
    extends MockBloc<CategoriesEvent, CategoriesState>
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

  testWidgets('displays empty state widget when no transactions', (tester) async {
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

  testWidgets('form displays validation errors when fields are empty', (tester) async {
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
