import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../core/extensions/l10n_x.dart';
import '../core/theme/app_spacing.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
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
        final authState = context.read<AuthCubit>().state;
        if (authState.user != null) {
          context.go(AppRoutes.dashboard);
        } else {
          context.go(AppRoutes.login);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'storage');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.huge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.extraLarge),
              Text(
                context.l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              if (error == null)
                const CircularProgressIndicator()
              else ...[
                Text(
                  context.l10n.storageInitializationFailed,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton(
                  onPressed: initialize,
                  child: Text(context.l10n.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
