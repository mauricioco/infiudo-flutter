import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  static const int maxLines = 5;
  
  final List<String> _log = <String>[];
  bool _isLoading = false;

  AppState();

  String get displayLog {
    if (_log.length > maxLines) {
      return _log.skip(1).join('\n');
    } else {
      return _log.join('\n');
    }
  }

  bool get isLoading {
    return _isLoading;
  }

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
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