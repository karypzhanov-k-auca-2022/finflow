import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/about_info_loader.dart';
import '../../domain/entities/about_info.dart';

typedef AboutInfoLoader = Future<AboutInfo> Function();

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, this.infoLoader});

  final AboutInfoLoader? infoLoader;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late Future<AboutInfo> _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _info = (widget.infoLoader ?? loadAboutInfo)();
  }

  void _retry() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.about)),
    body: SafeArea(
      child: FutureBuilder<AboutInfo>(
        future: _info,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.huge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phonelink_erase_outlined, size: 48),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      context.l10n.deviceInfoLoadError,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final info = snapshot.requireData;
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.extraLarge),
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    Card(
                      child: Column(
                        children: [
                          _InfoTile(
                            key: const Key('app_version'),
                            label: context.l10n.appVersion,
                            value: info.appVersion,
                          ),
                          const Divider(height: 1),
                          _InfoTile(
                            key: const Key('device_model'),
                            label: context.l10n.deviceModel,
                            value: info.deviceModel,
                          ),
                          const Divider(height: 1),
                          _InfoTile(
                            key: const Key('os_version'),
                            label: context.l10n.osVersion,
                            value: info.osVersion,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.large,
      vertical: AppSpacing.small,
    ),
    title: Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: AppSpacing.tiny),
      child: Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
  );
}
