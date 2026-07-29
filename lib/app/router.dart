import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/extensions/l10n_x.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/budgets/presentation/pages/budgets_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/settings/presentation/pages/about_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/transactions/domain/entities/transaction.dart';
import '../features/transactions/presentation/transaction_form/cubit/transaction_form_cubit.dart';
import '../features/transactions/presentation/transaction_form/pages/transaction_form_page.dart';
import '../features/transactions/presentation/transactions_list/bloc/transactions_bloc.dart';
import '../features/transactions/presentation/transactions_list/pages/transactions_page.dart';
import 'app_initializer.dart';
import 'dependency_injection.dart';
import 'splash_page.dart';

import '../features/auth/presentation/pages/login_page.dart';

GoRouter createRouter(AppInitializer initializer) => GoRouter(
  initialLocation: '/splash',
  restorationScopeId: 'router',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.pageNotFound)),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_off_outlined, size: 64),
          const SizedBox(height: 16),
          Text(context.l10n.routeDoesNotExist(state.uri.toString())),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/dashboard'),
            child: Text(context.l10n.home),
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
    GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
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
    GoRoute(path: '/categories', builder: (_, _) => const CategoriesPage()),
    GoRoute(path: '/about', builder: (_, _) => const AboutPage()),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) {
    void select(int index) =>
        shell.goBranch(index, initialLocation: index == shell.currentIndex);

    final labels = [
      context.l10n.home,
      context.l10n.transactions,
      context.l10n.budgets,
      context.l10n.analytics,
      context.l10n.settings,
    ];
    const icons = [
      (Icons.space_dashboard_outlined, Icons.space_dashboard),
      (Icons.receipt_long_outlined, Icons.receipt_long),
      (Icons.savings_outlined, Icons.savings),
      (Icons.bar_chart_outlined, Icons.bar_chart),
      (Icons.settings_outlined, Icons.settings),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: select,
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(
                    labels.length,
                    (index) => NavigationRailDestination(
                      icon: Icon(icons[index].$1),
                      selectedIcon: Icon(icons[index].$2),
                      label: Text(labels[index]),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: shell),
              ],
            ),
          );
        }

        return Scaffold(
          body: shell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: shell.currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            onDestinationSelected: select,
            destinations: List.generate(
              labels.length,
              (index) => NavigationDestination(
                icon: Icon(icons[index].$1),
                selectedIcon: Icon(icons[index].$2),
                label: labels[index],
              ),
            ),
          ),
        );
      },
    );
  }
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
          Text(context.l10n.transactionNotFound),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/transactions'),
            child: Text(context.l10n.backToTransactions),
          ),
        ],
      ),
    ),
  );
}
