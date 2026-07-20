import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/budgets/presentation/pages/budgets_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/settings/presentation/pages/about_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/transactions/domain/entities/transaction.dart';
import '../features/transactions/presentation/bloc/transaction_form_cubit.dart';
import '../features/transactions/presentation/bloc/transactions_bloc.dart';
import '../features/transactions/presentation/pages/transaction_form_page.dart';
import '../features/transactions/presentation/pages/transactions_page.dart';
import 'app_initializer.dart';
import 'dependency_injection.dart';
import 'splash_page.dart';

GoRouter createRouter(AppInitializer initializer) => GoRouter(
  initialLocation: '/splash',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Страница не найдена')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_off_outlined, size: 64),
          const SizedBox(height: 16),
          Text('Маршрут ${state.uri} не существует'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('На главную'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, _) => SplashPage(initializer: initializer),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, _) => const DashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (_, _) => const TransactionsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/budgets', builder: (_, _) => const BudgetsPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (_, _) => const AnalyticsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/transactions/new',
      builder: (_, _) => BlocProvider<TransactionFormCubit>(
        create: (_) => getIt(),
        child: const TransactionFormPage(),
      ),
    ),
    GoRoute(
      path: '/transactions/:id/edit',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        FinanceTransaction? item;
        for (final value in context.read<TransactionsBloc>().state.all) {
          if (value.id == id) item = value;
        }
        if (item == null) return const _MissingTransactionPage();
        return BlocProvider<TransactionFormCubit>(
          create: (_) => getIt(),
          child: TransactionFormPage(transaction: item),
        );
      },
    ),
    GoRoute(path: '/about', builder: (_, _) => const AboutPage()),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: (index) =>
          shell.goBranch(index, initialLocation: index == shell.currentIndex),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard),
          label: 'Главная',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Операции',
        ),
        NavigationDestination(
          icon: Icon(Icons.savings_outlined),
          selectedIcon: Icon(Icons.savings),
          label: 'Бюджеты',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Аналитика',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Настройки',
        ),
      ],
    ),
  );
}

class _MissingTransactionPage extends StatelessWidget {
  const _MissingTransactionPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Транзакция не найдена'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/transactions'),
            child: const Text('К списку'),
          ),
        ],
      ),
    ),
  );
}
