import 'package:flutter/foundation.dart';
import '../models/call.dart';

class CallProvider with ChangeNotifier {
  final List<Call> _calls = [];
  Call? _activeCall;

  List<Call> get calls => _calls;
  Call? get activeCall => _activeCall;

  void addCall(Call call) {
    _calls.insert(0, call);
    notifyListeners();
  }

  void setActiveCall(Call? call) {
    _activeCall = call;
    notifyListeners();
  }

  void removeCall(String name) {
    _calls.removeWhere((call) => call.name == name);
    notifyListeners();
  }

  void clearCallHistory() {
    _calls.clear();
    notifyListeners();
  }

  List<Call> searchCalls(String query) {
    if (query.isEmpty) return _calls;
    return _calls.where((call) => 
      call.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<Call> getMissedCalls() {
    return _calls.where((call) => call.isMissed).toList();
  }
}
