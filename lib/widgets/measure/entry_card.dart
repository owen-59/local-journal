import 'package:flutter/widgets.dart';
import 'package:journal/widgets/entry_card.dart';
import 'package:measured/measured.dart';

class EntryCardMeasurer extends StatelessWidget {
  final void Function(double) onChanged;
  const EntryCardMeasurer({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: Measured(
        onChanged: (size) => onChanged(size.height),
        child: EntryCard(
          entryDt: DateTime.now().copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
        ),
      ),
    );
  }
}
