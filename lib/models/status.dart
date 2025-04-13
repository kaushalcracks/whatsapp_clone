class Status {
  final String name;
  final String time;
  final bool isSeen;
  final String imageUrl;
  final String content;
  final Duration duration;
  final DateTime timestamp;

  const Status({
    required this.name,
    required this.time,
    required this.isSeen,
    this.imageUrl = '',
    this.content = '',
    this.duration = const Duration(seconds: 30),
    required this.timestamp,
  });

  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;
}
