import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/budgets/presentation/bloc/budgets_bloc.dart';
import '../features/categories/presentation/bloc/categories_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/settings/presentation/bloc/settings_cubit.dart';
import '../features/settings/presentation/bloc/theme_cubit.dart';
import '../features/transactions/presentation/bloc/transactions_bloc.dart';
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
      BlocProvider<CategoriesBloc>(create: (_) => getIt()),
      BlocProvider<DashboardBloc>(create: (_) => getIt()),
      BlocProvider<TransactionsBloc>(create: (_) => getIt()),
      BlocProvider<BudgetsBloc>(create: (_) => getIt()),
      BlocProvider<AnalyticsBloc>(create: (_) => getIt()),
      BlocProvider<ThemeCubit>(create: (_) => getIt()),
      BlocProvider<SettingsCubit>(create: (_) => getIt()),
    ],
    child: BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => MaterialApp.router(
        title: 'FinFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        routerConfig: router,
      ),
    ),
  );
}
