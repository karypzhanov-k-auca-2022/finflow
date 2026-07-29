import 'dart:async';
import 'package:finflow/core/connectivity/connection_cubit.dart';
import 'package:finflow/core/connectivity/connection_monitor.dart';
import 'package:finflow/core/connectivity/offline_gate.dart';
import 'package:finflow/core/extensions/l10n_x.dart';
import 'package:finflow/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeConnectionMonitor implements ConnectionMonitor {
  FakeConnectionMonitor(this.online);

  bool online;
  final controller = StreamController<bool>.broadcast();

  @override
  Future<bool> hasConnection() async => online;

  @override
  Stream<bool> get onConnectionChanged => controller.stream;

  void setOnline(bool value) {
    online = value;
    controller.add(value);
  }

  Future<void> close() => controller.close();
}

Widget _localizedApp({
  required Widget home,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('renders Russian localization', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        locale: const Locale('ru'),
        home: Builder(
          builder: (context) => Scaffold(body: Text(context.l10n.transactions)),
        ),
      ),
    );

    expect(find.text('Операции'), findsOneWidget);
  });

  testWidgets('shows offline screen and allows local continuation', (
    tester,
  ) async {
    final monitor = FakeConnectionMonitor(false);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ConnectionCubit(monitor),
        child: _localizedApp(
          home: const OfflineGate(child: Scaffold(body: Text('local-content'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offline_page')), findsOneWidget);
    expect(find.text('You are offline'), findsOneWidget);

    await tester.tap(find.text('Continue offline'));
    await tester.pumpAndSettle();

    expect(find.text('local-content'), findsOneWidget);
    expect(find.text('Offline mode'), findsOneWidget);

    monitor.setOnline(true);
    await tester.pumpAndSettle();

    expect(find.text('Offline mode'), findsNothing);
    await monitor.close();
  });
}
