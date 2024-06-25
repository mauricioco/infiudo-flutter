import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  static const int maxLines = 5;
  
  List<String> _log = <String>[];
  bool _isWatching = false;

  AppState();

  String get displayLog {
    if (_log.length > maxLines) {
      return _log.skip(1).join('\n');
    } else {
      return _log.join('\n');
    }
  }

  bool get isWatching {
    return _isWatching;
  }

  set isWatching(bool isWatching) {
    _isWatching = isWatching;
    notifyListeners();
  }

  void appendLog(String newLine) {
    if (_log.length >= maxLines+1) {
      _log.removeAt(0);
    }
    _log.add(newLine);
    notifyListeners();
  }

  void removeFirstLine() {
    if (_log.isNotEmpty) {
      _log.removeAt(0);
      notifyListeners();
    }
  }

}