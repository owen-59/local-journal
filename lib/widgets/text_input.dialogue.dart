import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({super.key});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Details'),
      content: TextField(
        controller: _textController,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Your Name',
          hintText: 'John Doe',
          border: OutlineInputBorder(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final enteredText = _textController.text;
            Navigator.pop(context, enteredText);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
