import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

Future<bool> showConfirmDelete(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l10n.deleteItemTitle),
      content: Text(l10n.deleteCannotUndo),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            l10n.delete,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  return result == true;
}
