import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../extensions/l10n_x.dart';
import '../theme/app_spacing.dart';
import 'connection_cubit.dart';

class OfflineGate extends StatefulWidget {
  const OfflineGate({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineGate> createState() => _OfflineGateState();
}

class _OfflineGateState extends State<OfflineGate> {
  bool _continueOffline = false;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ConnectionCubit, ConnectionStatus>(
        listenWhen: (previous, current) =>
            previous != current && current == ConnectionStatus.online,
        listener: (context, state) {
          if (_continueOffline) setState(() => _continueOffline = false);
        },
        builder: (context, status) {
          if (status == ConnectionStatus.offline && !_continueOffline) {
            return _OfflinePage(
              onRetry: context.read<ConnectionCubit>().recheck,
              onContinue: () => setState(() => _continueOffline = true),
            );
          }

          return Stack(
            children: [
              widget.child,
              if (status == ConnectionStatus.offline)
                Positioned(
                  top: MediaQuery.paddingOf(context).top,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.large,
                          vertical: AppSpacing.compact,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off_outlined, size: 18),
                            const SizedBox(width: AppSpacing.small),
                            Text(
                              context.l10n.offlineMode,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

class _OfflinePage extends StatelessWidget {
  const _OfflinePage({required this.onRetry, required this.onContinue});

  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('offline_page'),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.huge),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_cellular_connected_no_internet_4_bar,
                  size: 88,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.section),
                Text(
                  context.l10n.offlineTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(context.l10n.offlineMessage, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sectionLarge),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.checkAgain),
                ),
                const SizedBox(height: AppSpacing.small),
                TextButton(
                  onPressed: onContinue,
                  child: Text(context.l10n.continueOffline),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
