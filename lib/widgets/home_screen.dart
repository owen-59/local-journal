import 'package:flutter/material.dart';
import 'package:journal/widgets/entry_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Journal")),
      body: EntryList(),
    );
  }
}
