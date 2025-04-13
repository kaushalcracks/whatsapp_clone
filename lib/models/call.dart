class Call {
  final String name;
  final String time;
  final bool isIncoming;
  final bool isMissed;
  final bool isVideo;
  final String avatarUrl;
  final DateTime timestamp;

  const Call({
    required this.name,
    required this.time,
    required this.isIncoming,
    required this.isMissed,
    this.isVideo = false,
    this.avatarUrl = '',
    required this.timestamp,
  });

  String get timeFormatted {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}