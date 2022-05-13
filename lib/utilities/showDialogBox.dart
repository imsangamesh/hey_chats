import 'package:flutter/material.dart';

void kshowErrorDialog({
  required String errorMessage,
  required BuildContext context,
  String? body,
}) {
  showDialog(
    barrierColor: Theme.of(context).colorScheme.secondary.withAlpha(100),
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        errorMessage,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.redAccent,
        ),
      ),
      content: body == null ? null : Text(body),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.check),
          label: const Text('Ok'),
        ),
      ],
    ),
  );
}

void kshowConfirmDialog({
  required BuildContext context,
  required String heading,
  required Function leftFun,
  required IconData li,
  required String liName,
  required Function rightFun,
  required IconData ri,
  required String riName,
  String? body,
}) {
  showDialog(
    barrierColor: Theme.of(context).colorScheme.secondary.withAlpha(100),
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        heading,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      content: body != null ? Text(body) : null,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () => leftFun(),
              icon: Icon(li),
              label: Text(liName),
            ),
            TextButton.icon(
              onPressed: () => rightFun(),
              icon: Icon(ri),
              label: Text(riName),
            ),
          ],
        )
      ],
    ),
  );
}
