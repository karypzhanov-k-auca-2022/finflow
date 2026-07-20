import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/core/error/failure.dart';
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
import '../helpers.dart';

class MockTransactionsBloc
    extends MockBloc<TransactionsEvent, TransactionsState>
    implements TransactionsBloc {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU');
    registerFallbackValue(const TransactionsRequested());
  });

  testWidgets('отображает loading', (tester) async {
    final bloc = _bloc(
      const TransactionsState(status: TransactionsStatus.loading),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('отображает empty state', (tester) async {
    final bloc = _bloc(
      const TransactionsState(status: TransactionsStatus.empty),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.text('Нет транзакций'), findsOneWidget);
  });

  testWidgets('отображает список транзакций', (tester) async {
    final item = transaction(title: 'Проверочная покупка');
    final bloc = _bloc(
      TransactionsState(
        status: TransactionsStatus.success,
        all: [item],
        visible: [item],
      ),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.text('Проверочная покупка'), findsOneWidget);
  });

  testWidgets('error state содержит Retry и отправляет событие', (
    tester,
  ) async {
    final bloc = _bloc(
      const TransactionsState(
        status: TransactionsStatus.failure,
        failure: CacheFailure(),
      ),
    );
    await tester.pumpWidget(_transactionsApp(bloc));
    expect(find.text('Повторить'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    verify(() => bloc.add(any(that: isA<TransactionsRequested>()))).called(1);
  });

  testWidgets('форма показывает ошибки валидации', (tester) async {
    final repository = MockTransactionRepository();
    final cubit = TransactionFormCubit(TransactionUseCases(repository));
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const TransactionFormPage(),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Сохранить'));
    await tester.tap(find.text('Сохранить'));
    await tester.pump();
    expect(find.text('Введите название'), findsOneWidget);
    expect(find.text('Введите положительную сумму'), findsOneWidget);
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

Widget _transactionsApp(TransactionsBloc bloc) => MaterialApp(
  home: BlocProvider<TransactionsBloc>.value(
    value: bloc,
    child: const TransactionsPage(),
  ),
);
