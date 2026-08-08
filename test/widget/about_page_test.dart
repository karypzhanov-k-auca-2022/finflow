import 'package:finflow/features/settings/domain/entities/about_info.dart';
import 'package:finflow/features/settings/presentation/pages/about_page.dart';
import 'package:finflow/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows app, phone model, and OS information', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AboutPage(
          infoLoader: () async => const AboutInfo(
            appVersion: '1.0.0',
            deviceModel: 'Xiaomi 2311DRK48G',
            osVersion: 'Android 16',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app_version')), findsOneWidget);
    expect(find.byKey(const Key('device_model')), findsOneWidget);
    expect(find.byKey(const Key('os_version')), findsOneWidget);
    expect(find.text('Версия приложения'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('Модель'), findsOneWidget);
    expect(find.text('Xiaomi 2311DRK48G'), findsOneWidget);
    expect(find.text('Версия ОС'), findsOneWidget);
    expect(find.text('Android 16'), findsOneWidget);
  });
}
