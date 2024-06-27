import 'package:flutter/material.dart';
import 'package:infiudo/app_state.dart';
import 'package:provider/provider.dart';

class GlobalLoadingWidget extends StatefulWidget {
  const GlobalLoadingWidget({super.key});

  @override
  State<GlobalLoadingWidget> createState() => _GlobalLoadingWidgetState();
}

class _GlobalLoadingWidgetState extends State<GlobalLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Opacity(
            opacity: 0.5,
            child: ModalBarrier(dismissible: false, color: Colors.black)
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}