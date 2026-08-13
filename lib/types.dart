class Entry implements Comparable<Entry> {
  final String body;
  final DateTime datetime;

  Entry({required this.body, required this.datetime});

  @override
  int compareTo(Entry other) {
    return datetime.compareTo(other.datetime);
  }
}
