import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/state_views.dart';
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
              onSelectionChanged: (value) =>
                  context.read<ThemeCubit>().setMode(value.first),
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
}
