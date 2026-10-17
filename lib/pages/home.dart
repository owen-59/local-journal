import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/logger.dart';
import 'package:journal/providers/entry_list.dart';
import 'package:journal/widgets/entry_list.dart' as wid;
import 'package:journal/widgets/map.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentPageIndex = 0;
  final _pageController = PageController();
  final GlobalKey<wid.EntryListState> _entryListKey = GlobalKey();

  late final List<Widget> _screens = [
    wid.EntryList(key: _entryListKey),
    MapPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Journal"),
        actions: [
          ?_currentPageIndex == 0
            ? IconButton(
              icon: Icon(Icons.calendar_month),
              onPressed: () => onDateClicked(context, ref),
            )
            : null
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.map), label: "Map"),
        ],
      ),
      floatingActionButton: _currentPageIndex == 0
          ? FloatingActionButton(
              onPressed: () => createEntry(context, ref),
              child: const Icon(Icons.create),
            )
          : null,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _screens,
      ),
    );
  }

  Future<void> createEntry(BuildContext context, WidgetRef ref) async {
    final entryDatetime = await ref.read(entryListProvider.notifier).newEntry();

    if (context.mounted) {
      context.push("/entry/$entryDatetime");
    } else {
      logger.w("Created an entry, but the context was no longer valid.");
    }
  }

  void onDateClicked(BuildContext context, WidgetRef ref) {
    ref.read(entryListProvider).whenData((entries) async {
      final chosenDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().isAfter(entries.first)
            ? entries.first
            : DateTime.now().isBefore(entries.last)
            ? entries.last
            : DateTime.now(),
        firstDate: entries.last,
        lastDate: entries.first,
      );
      if (chosenDate == null) return;

      _entryListKey.currentState?.jumpToDate(chosenDate, entries);
    });
  }
}
