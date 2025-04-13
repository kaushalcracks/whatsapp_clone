class Message {
  final String text;
  final bool isSent;
  final String time;
  final String senderId;
  final bool isRead;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isSent,
    required this.time,
    required this.senderId,
    this.isRead = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
