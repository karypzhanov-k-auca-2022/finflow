import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../core/extensions/l10n_x.dart';
import '../core/connectivity/connection_cubit.dart';
import '../core/connectivity/offline_gate.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_background.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/budgets/presentation/bloc/budgets_bloc.dart';
import '../features/categories/presentation/bloc/categories_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/settings/presentation/bloc/settings_cubit.dart';
import '../features/settings/presentation/bloc/locale_cubit.dart';
import '../features/settings/presentation/bloc/theme_cubit.dart';
import '../features/transactions/presentation/transactions_list/bloc/transactions_bloc.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import 'app_initializer.dart';
import 'dependency_injection.dart';
import 'router.dart';

class FinFlowApp extends StatefulWidget {
  const FinFlowApp({super.key});
  @override
  State<FinFlowApp> createState() => _FinFlowAppState();
}

class _FinFlowAppState extends State<FinFlowApp> {
  late final router = createRouter(getIt<AppInitializer>());
  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>(create: (_) => getIt()),
      BlocProvider<ConnectionCubit>(create: (_) => getIt()),
      BlocProvider<CategoriesBloc>(create: (_) => getIt()),
      BlocProvider<DashboardBloc>(create: (_) => getIt()),
      BlocProvider<TransactionsBloc>(create: (_) => getIt()),
      BlocProvider<BudgetsBloc>(create: (_) => getIt()),
      BlocProvider<AnalyticsBloc>(create: (_) => getIt()),
      BlocProvider<ThemeCubit>(create: (_) => getIt()),
      BlocProvider<LocaleCubit>(create: (_) => getIt()),
      BlocProvider<SettingsCubit>(create: (_) => getIt()),
    ],
    child: BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) => BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          Intl.defaultLocale = locale.toLanguageTag();
          return MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            restorationScopeId: 'finflow',
            routerConfig: router,
            builder: (context, child) => AppBackground(
              child: OfflineGate(child: child ?? const SizedBox.shrink()),
            ),
          );
        },
      ),
    ),
  );
}
