import 'package:flutter/material.dart';
import '../../../../core/extensions/l10n_x.dart';
import '../../../../core/theme/app_spacing.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.about)),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.huge),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.extraLarge),
              Text(
                context.l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(context.l10n.personalFinanceTracker),
              const SizedBox(height: AppSpacing.section),
              Text(context.l10n.aboutDescription, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}
