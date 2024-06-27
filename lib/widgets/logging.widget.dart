import 'package:flutter/material.dart';
import 'package:infiudo/app_state.dart';
import 'package:provider/provider.dart';

class LoggingWidget extends StatefulWidget {
  const LoggingWidget({super.key});

  @override
  State<LoggingWidget> createState() => LoggingWidgetState();
}

class LoggingWidgetState extends State<LoggingWidget> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 256, minHeight: 0),
        child:
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.5),
            ),
            child:
              Consumer<AppState>(
                builder: (context, appState, child) {
                  return DefaultTextStyle(
                      style: const TextStyle(fontSize: 14),
                      child: Text(appState.displayLog)
                  );
                },
              )
          )
      )
    );
  }
}