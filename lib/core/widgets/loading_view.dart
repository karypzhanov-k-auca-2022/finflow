import 'package:flutter/material.dart';

import '../extensions/l10n_x.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: label ?? context.l10n.loadingData,
      child: const CircularProgressIndicator(),
    ),
  );
}
