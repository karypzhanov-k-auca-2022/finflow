import 'package:finflow/app/app_routes.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/core/theme/app_theme.dart';
import 'package:finflow/features/auth/domain/entities/app_user.dart';
import 'package:finflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:finflow/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:finflow/features/auth/presentation/pages/login_page.dart';
import 'package:finflow/features/auth/presentation/pages/register_page.dart';
import 'package:finflow/features/settings/domain/settings_repository.dart';
import 'package:finflow/features/settings/presentation/bloc/locale_cubit.dart';
import 'package:finflow/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockAuthRepository repository;
  late MockSettingsRepository settingsRepository;
  late AuthCubit cubit;
  late LocaleCubit localeCubit;
  late GoRouter router;

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.currentUser).thenReturn(null);
    when(
      () => repository.onAuthStateChanged,
    ).thenAnswer((_) => const Stream<AppUser?>.empty());
    settingsRepository = MockSettingsRepository();
    when(() => settingsRepository.loadLocale()).thenReturn(const Locale('en'));
    when(
      () => settingsRepository.saveLocale(const Locale('ru')),
    ).thenAnswer((_) async {});
    cubit = AuthCubit(repository);
    localeCubit = LocaleCubit(settingsRepository);
    router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, _) => const RegisterPage(),
        ),
      ],
    );
  });

  tearDown(() async {
    router.dispose();
    await cubit.close();
    await localeCubit.close();
  });

  Future<void> pumpAuthApp(WidgetTester tester) => tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: cubit),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp.router(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    ),
  );

  testWidgets('language switcher stays available across auth routes', (
    tester,
  ) async {
    await pumpAuthApp(tester);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('auth-language-switcher')),
      findsOneWidget,
    );

    await tester.tap(find.text('RU'));
    await tester.pumpAndSettle();

    expect(find.text('С возвращением'), findsOneWidget);
    verify(() => settingsRepository.saveLocale(const Locale('ru'))).called(1);

    await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('auth-language-switcher')),
      findsOneWidget,
    );
    expect(find.text('Создать аккаунт FinFlow'), findsOneWidget);
  });

  testWidgets('login and registration are separate routes', (tester) async {
    await pumpAuthApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Repeat password'), findsNothing);
    expect(find.text('Continue as guest'), findsOneWidget);

    await tester.tap(find.text('No account? Register'));
    await tester.pumpAndSettle();

    expect(find.text('Create a FinFlow account'), findsOneWidget);
    expect(find.text('Repeat password'), findsOneWidget);
    expect(find.text('Continue as guest'), findsNothing);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
  });

  testWidgets('login form submits email and password', (tester) async {
    when(
      () => repository.signInWithEmail('person@example.com', '123456'),
    ).thenAnswer(
      (_) async =>
          const Success(AppUser(uid: 'user-1', email: 'person@example.com')),
    );

    await pumpAuthApp(tester);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'person@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in to account'));
    await tester.pump();

    verify(
      () => repository.signInWithEmail('person@example.com', '123456'),
    ).called(1);
  });

  testWidgets('registration form submits matching passwords', (tester) async {
    when(
      () => repository.signUpWithEmail('new@example.com', '123456'),
    ).thenAnswer(
      (_) async =>
          const Success(AppUser(uid: 'user-2', email: 'new@example.com')),
    );

    await pumpAuthApp(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No account? Register'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'new@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.tap(find.text('Register'));
    await tester.pump();

    verify(
      () => repository.signUpWithEmail('new@example.com', '123456'),
    ).called(1);
  });
}
