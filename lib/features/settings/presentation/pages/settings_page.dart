import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<SettingsCubit, SettingsActionState>(
    listener: (context, state) {
      if (state.status == SettingsActionStatus.success ||
          state.status == SettingsActionStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message)));
      }
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final user = authState.user;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(user?.isAnonymous ?? true ? Icons.person_outline : Icons.account_circle),
                  ),
                  title: Text(user?.displayName ?? 'Not logged in'),
                  subtitle: Text(user?.isAnonymous ?? true ? 'Guest Account' : 'Cloud Sync Active'),
                  trailing: TextButton.icon(
                    onPressed: () {
                      if (user != null) {
                        context.read<AuthCubit>().signOut();
                      } else {
                        context.push('/login');
                      }
                    },
                    icon: Icon(user != null ? Icons.logout : Icons.login, size: 18),
                    label: Text(user != null ? 'Sign Out' : 'Sign In'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) => SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest_outlined),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (value) {
                HapticFeedback.selectionClick();
                context.read<ThemeCubit>().setMode(value.first);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('Categories', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Manage categories'),
              subtitle: const Text('View and create categories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/categories'),
            ),
          ),
          const SizedBox(height: 28),
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          BlocBuilder<SettingsCubit, SettingsActionState>(
            builder: (context, state) {
              final disabled = state.status == SettingsActionStatus.working;
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      enabled: !disabled,
                      leading: const Icon(Icons.file_download_outlined),
                      title: const Text('Export transactions to CSV'),
                      subtitle: const Text('Save or copy financial records'),
                      onTap: disabled ? null : () => _exportCsv(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      enabled: !disabled,
                      leading: const Icon(Icons.delete_sweep_outlined),
                      title: const Text('Clear data'),
                      subtitle: const Text('Delete transactions and budgets'),
                      onTap: disabled
                          ? null
                          : () async {
                              if (await showConfirmation(
                                    context,
                                    title: 'Clear all data?',
                                    message:
                                        'Transactions and budgets will be deleted.',
                                    confirmLabel: 'Clear',
                                  ) &&
                                  context.mounted) {
                                await context.read<SettingsCubit>().clearData();
                              }
                            },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      enabled: !disabled,
                      leading: const Icon(Icons.restart_alt),
                      title: const Text('Restore demo data'),
                      subtitle: const Text(
                        'Replace current data with demo data',
                      ),
                      trailing: disabled
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onTap: disabled
                          ? null
                          : () async {
                              if (await showConfirmation(
                                    context,
                                    title: 'Restore demo data?',
                                    message:
                                        'Current transactions and budgets will be replaced.',
                                    confirmLabel: 'Restore',
                                  ) &&
                                  context.mounted) {
                                await context.read<SettingsCubit>().seedData();
                              }
                            },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('FinFlow 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/about'),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _exportCsv(BuildContext context) async {
    final res = await getIt<TransactionUseCases>().load();
    if (!context.mounted) return;

    if (res is Success<TransactionsResult>) {
      final csv = CsvExporter.exportTransactions(res.data.transactions);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Export CSV'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated ${res.data.transactions.length} transaction(s) in CSV format:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      csv,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: csv));
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV copied to clipboard!')),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy'),
            ),
          ],
        ),
      );
    }
  }
}
