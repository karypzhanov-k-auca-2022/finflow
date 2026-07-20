import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/budgets/presentation/bloc/budgets_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/transactions/presentation/bloc/transactions_bloc.dart';
import 'app_initializer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.initializer});
  final AppInitializer initializer;
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String? error;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      await widget.initializer.initialize();
      if (mounted) {
        context.read<DashboardBloc>().add(const DashboardRequested());
        context.read<TransactionsBloc>().add(const TransactionsRequested());
        context.read<BudgetsBloc>().add(const BudgetsRequested());
        context.read<AnalyticsBloc>().add(const AnalyticsRequested());
        context.go('/dashboard');
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Не удалось подготовить локальное хранилище');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'FinFlow',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (error == null)
                const CircularProgressIndicator()
              else ...[
                Text(error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: initialize,
                  child: const Text('Повторить'),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
