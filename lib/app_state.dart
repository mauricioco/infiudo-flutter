import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  //TODO bring isLoading here
  static const int maxLines = 5;
  
  List<String> log = <String>[];

  AppState();

  String get displayLog {
    if (log.length > maxLines) {
      return log.skip(1).join('\n');
    } else {
      return log.join('\n');
    }
  }

  void appendLog(String newLine) {
    if (log.length >= maxLines+1) {
      log.removeAt(0);
    }
    log.add(newLine);
    notifyListeners();
  }

  void removeFirstLine() {
    if (log.isNotEmpty) {
      log.removeAt(0);
      notifyListeners();
    }
  }

}