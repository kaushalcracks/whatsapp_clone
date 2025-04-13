class Contact {
  final String name;
  final String phoneNumber;
  final String? status;
  final String? imageUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  const Contact({
    required this.name,
    required this.phoneNumber,
    this.status,
    this.imageUrl,
    this.isOnline = false,
    this.lastSeen,
  });
}
