import 'package:flutter/material.dart';
import 'package:journal/types.dart';

class EntryCard extends StatelessWidget {
    final Entry entry;

    const EntryCard({
        super.key,
        required this.entry,
    });

    @override
        Widget build(BuildContext context) {
            return GestureDetector(
                child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(entry.body),
                            Text(entry.date.toString()),
                        ],
                    )
                ),
            );
        }
}
