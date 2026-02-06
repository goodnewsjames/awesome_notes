import 'package:awesome_notes/widgets/confirmation_dialog.dart';
import 'package:awesome_notes/widgets/message_dialog.dart';
import 'package:awesome_notes/widgets/new_tag_dialog.dart';
import 'package:flutter/material.dart';

Future<String?> showNewTagDialog({
  required BuildContext context,
  String? tag,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        NewTagDialog(tag: tag),
  );
}

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String dialog,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (_) => ConfrimationDialog(dialogText: dialog),
  );
}


Future<bool?> showMessageDialog({
  required BuildContext context,
  required String message,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (_) => MessageDialog(message: message),
  );
}
