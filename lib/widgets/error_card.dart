import 'package:flutter/material.dart';
import 'package:stack_trace/stack_trace.dart';

class ErrorCard extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const ErrorCard({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          border: Border.all(color: Theme.of(context).colorScheme.error),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString(), style: TextStyle(fontSize: 16.0)),
              ExpansionTile(
                title: const Text("Stack trace"),
                shape: Border.all(color: Colors.transparent),
                children: [
                  Text(
                    Trace.from(stackTrace).terse
                        .toString()
                        .split("\n")
                        .where((line) => line.trim().isNotEmpty)
                        .join("\n"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
