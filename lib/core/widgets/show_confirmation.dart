import 'package:flutter/material.dart';

import '../extensions/l10n_x.dart';

Future<bool> showConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel ?? context.l10n.delete),
          ),
        ],
      ),
    ) ??
    false;
