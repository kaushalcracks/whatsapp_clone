class DateFormatter {
  static String getVerboseDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      switch (dateTime.weekday) {
        case 1:
          return 'Monday';
        case 2:
          return 'Tuesday';
        case 3:
          return 'Wednesday';
        case 4:
          return 'Thursday';
        case 5:
          return 'Friday';
        case 6:
          return 'Saturday';
        case 7:
          return 'Sunday';
        default:
          return '';
      }
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  static String getMessageTime(DateTime dateTime) {
    String addLeadingZero(int number) => number.toString().padLeft(2, '0');
    final hour = addLeadingZero(dateTime.hour);
    final minute = addLeadingZero(dateTime.minute);
    return '$hour:$minute';
  }

  static String getLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'online';
    } else if (difference.inMinutes < 60) {
      return 'last seen ${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return 'last seen ${difference.inHours} hours ago';
    } else {
      return 'last seen ${getVerboseDate(dateTime)}';
    }
  }
}
