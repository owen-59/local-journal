import 'package:flutter/widgets.dart';
import 'package:journal/widgets/entry_card_seperator.dart';
import 'package:measured/measured.dart';

class EntrySeparatorWithoutTextMeasurer extends StatelessWidget {
  final void Function(double) onChanged;
  const EntrySeparatorWithoutTextMeasurer({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: Measured(
        onChanged: (size) => onChanged(size.height),
        child: EntryCardSeperator(
          aboveEntryDt: DateTime(1970),
          belowEntryDt: DateTime(1970),
        ),
      ),
    );
  }
}
