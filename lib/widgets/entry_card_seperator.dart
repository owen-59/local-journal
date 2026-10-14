import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntryCardSeperator extends StatelessWidget {
  final DateTime aboveEntryDt;
  final DateTime belowEntryDt;

  const EntryCardSeperator({
    super.key,
    required this.aboveEntryDt,
    required this.belowEntryDt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        aboveEntryDt.month == belowEntryDt.month &&
                aboveEntryDt.year == belowEntryDt.year
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 20,
                  vertical: 4.0,
                ),
                child: Text(
                  DateFormat.yMMMM().format(belowEntryDt),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
        Divider(),
      ],
    );
  }
}
