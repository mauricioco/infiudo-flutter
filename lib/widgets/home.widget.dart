import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infiudo/app_state.dart';
import 'package:infiudo/widgets/new_watch.widget.dart';
import 'package:infiudo/widgets/result_list.widget.dart';
//import 'package:infiudo/widgets/service_list.widget.dart';
import 'package:infiudo/widgets/watch_list.widget.dart';
import 'package:provider/provider.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() =>
      _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  
  int _selectedIndex = 0;
  bool _showFab = false;

  int _countHack = 0;   // TODO: this is a hacky way to refresh the Watch List

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        Provider.of<AppState>(context, listen: false).removeFirstLine();
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showFab = index == 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child:IndexedStack(
              index: _selectedIndex, 
              children:[
                const ResultListWidget(),
                WatchListWidget(key: ValueKey(_countHack)),
                //const ServiceListWidget(),
              ]
            )
          ),
          IgnorePointer(
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
                        return Text(appState.displayLog);
                      },
                    )
                    /*Text.rich(
                      TextSpan(
                        text: _logtext,
                      ),
                    )*/
                )
            )
          )
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'New In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'Watches',
          ),
          //BottomNavigationBarItem(
          //  icon: Icon(Icons.public),
          //  label: 'Services',
          //),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurpleAccent,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _showFab ? FloatingActionButton(
        onPressed: () {
          _countHack++;
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NewWatchWidget())).then((_) => setState(() {}));
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}
