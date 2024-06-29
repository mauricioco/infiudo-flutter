import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infiudo/app_state.dart';
import 'package:infiudo/widgets/global_loading.widget.dart';
import 'package:infiudo/widgets/logging.widget.dart';
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
  final ScrollController _hideButtonController = ScrollController();

  int _countHack = 0;   // TODO: this is a hacky way to refresh the Watch List

  @override
  void initState() {
    super.initState();
    _hideButtonController.addListener((){
      if(_hideButtonController.position.userScrollDirection == ScrollDirection.reverse){
        if(_showFab == true) {
            /* only set when the previous state is false
             * Less widget rebuilds 
             */
            setState((){
              _showFab = false;
            });
        }
      } else {
        if(_hideButtonController.position.userScrollDirection == ScrollDirection.forward){
          if(_showFab == false) {
              /* only set when the previous state is false
               * Less widget rebuilds 
               */
               setState((){
                 _showFab = true;
               });
           }
        }
    }});
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!Provider.of<AppState>(context, listen: false).isLoading) {
          Provider.of<AppState>(context, listen: false).removeFirstLine();
        }
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showFab = index == 1;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: 
        Stack(
        children: [
          Scaffold(
            body: Stack(
              children: [
                SafeArea(
                  child:
                    IndexedStack(
                    index: _selectedIndex, 
                    children:[
                      const ResultListWidget(),
                      WatchListWidget(key: ValueKey(_countHack), hideButtonController: _hideButtonController),
                      //const ServiceListWidget(),
                    ]
                  )
                ),
                const GlobalLoadingWidget()
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
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(360))),
              onPressed: () {
                _countHack++;
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NewWatchWidget())).then((_) => setState(() {}));
              },
              child: const Icon(Icons.add),
            ) : null,
          ),
          const GlobalLoadingWidget(),
          const LoggingWidget()
        ]
      )
    );
  }
}