import 'package:flutter/material.dart';

class ConfirmDialogue extends StatelessWidget {
  final String titleText;
  final String description;
  final String cancelText;
  final String confirmText;
  final bool isDestructive;

  const ConfirmDialogue({
    super.key,
    required this.titleText,
    required this.description,
    required this.cancelText,
    required this.confirmText,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleText),
      content: Text(description),
      actions: [
        TextButton(
          child: Text(cancelText),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDestructive
              ? TextButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
