import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/extensions/l10n_x.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/locale_cubit.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (state.message) {
              'Data cleared' => context.l10n.dataCleared,
              'Demo data restored' => context.l10n.demoDataRestored,
              _ => state.message,
            }),
          ),
        );
      }
    },
    child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                context.l10n.account,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final user = authState.user;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          user?.isAnonymous ?? true
                              ? Icons.person_outline
                              : Icons.account_circle,
                        ),
                      ),
                      title: Text(
                        user?.displayName ?? context.l10n.notLoggedIn,
                      ),
                      subtitle: Text(
                        user?.isAnonymous ?? true
                            ? context.l10n.guestAccount
                            : context.l10n.cloudSyncActive,
                      ),
                      trailing: TextButton.icon(
                        onPressed: () async {
                          if (user != null) {
                            await context.read<AuthCubit>().signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          } else {
                            await context.push('/login');
                          }
                        },
                        icon: Icon(
                          user != null ? Icons.logout : Icons.login,
                          size: 18,
                        ),
                        label: Text(
                          user != null
                              ? context.l10n.signOut
                              : context.l10n.signIn,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.theme,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) => SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(
                        Icons.settings_suggest_outlined,
                        size: 18,
                      ),
                      label: Text(
                        context.l10n.system,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined, size: 18),
                      label: Text(
                        context.l10n.light,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined, size: 18),
                      label: Text(
                        context.l10n.dark,
                        style: const TextStyle(fontSize: 13),
                      ),
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
              Text(
                context.l10n.language,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) => SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'en',
                      label: Text(context.l10n.english),
                    ),
                    ButtonSegment(
                      value: 'ru',
                      label: Text(context.l10n.russian),
                    ),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (value) {
                    HapticFeedback.selectionClick();
                    context.read<LocaleCubit>().setLocale(Locale(value.first));
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.categoriesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(context.l10n.manageCategories),
                  subtitle: Text(context.l10n.manageCategoriesSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/categories'),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                context.l10n.data,
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                          title: Text(context.l10n.exportTransactionsCsv),
                          subtitle: Text(
                            context.l10n.exportTransactionsCsvSubtitle,
                          ),
                          onTap: disabled ? null : () => _exportCsv(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          enabled: !disabled,
                          leading: const Icon(Icons.delete_sweep_outlined),
                          title: Text(context.l10n.clearData),
                          subtitle: Text(context.l10n.clearDataSubtitle),
                          onTap: disabled
                              ? null
                              : () async {
                                  if (await showConfirmation(
                                        context,
                                        title:
                                            context.l10n.clearAllDataQuestion,
                                        message:
                                            context.l10n.clearAllDataMessage,
                                        confirmLabel: context.l10n.clear,
                                      ) &&
                                      context.mounted) {
                                    await context
                                        .read<SettingsCubit>()
                                        .clearData();
                                  }
                                },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          enabled: !disabled,
                          leading: const Icon(Icons.restart_alt),
                          title: Text(context.l10n.restoreDemoData),
                          subtitle: Text(context.l10n.restoreDemoDataSubtitle),
                          trailing: disabled
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                          onTap: disabled
                              ? null
                              : () async {
                                  if (await showConfirmation(
                                        context,
                                        title: context
                                            .l10n
                                            .restoreDemoDataQuestion,
                                        message:
                                            context.l10n.restoreDemoDataMessage,
                                        confirmLabel: context.l10n.restore,
                                      ) &&
                                      context.mounted) {
                                    await context
                                        .read<SettingsCubit>()
                                        .seedData();
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
                  title: Text(context.l10n.about),
                  subtitle: const Text('FinFlow 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/about'),
                ),
              ),
            ],
          ),
        ),
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
          title: Text(context.l10n.exportCsv),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.csvGenerated(res.data.transactions.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
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
              child: Text(context.l10n.close),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: csv));
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.csvCopied)),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(context.l10n.copy),
            ),
          ],
        ),
      );
    }
  }
}
