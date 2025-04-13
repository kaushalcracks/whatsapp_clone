import 'package:flutter/foundation.dart';
import '../models/status.dart';

class StatusProvider with ChangeNotifier {
  final List<Status> _statuses = [];
  Status? _myStatus;

  List<Status> get statuses => _statuses;
  Status? get myStatus => _myStatus;

  void addStatus(Status status) {
    _statuses.insert(0, status);
    notifyListeners();
  }

  void updateMyStatus(Status status) {
    _myStatus = status;
    notifyListeners();
  }

  void markStatusAsSeen(String name) {
    final statusIndex = _statuses.indexWhere((status) => status.name == name);
    if (statusIndex != -1) {
      final status = _statuses[statusIndex];
      _statuses[statusIndex] = Status(
        name: status.name,
        time: status.time,
        isSeen: true,
        imageUrl: status.imageUrl,
        timestamp: status.timestamp,
      );
      notifyListeners();
    }
  }

  List<Status> getRecentUpdates() {
    return _statuses.where((status) => status.isRecent).toList();
  }

  void removeExpiredStatuses() {
    _statuses.removeWhere((status) => 
      DateTime.now().difference(status.timestamp).inHours >= 24);
    notifyListeners();
  }
}