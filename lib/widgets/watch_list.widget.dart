// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/watch.dart';

class WatchListItem extends StatelessWidget {

  final VoidCallback onDeleteClicked;

  final Watch watch;
  final String thumbnailUrl;    // Either service thumbnail or custom
  
  const WatchListItem.fromWatch(this.watch, this.thumbnailUrl, {super.key, required this.onDeleteClicked});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Center(
        child: ListTile(
          leading: Image.network(thumbnailUrl),
          title: Text(Uri.decodeComponent(watch.query)),
          trailing: IconButton(
            onPressed: onDeleteClicked,
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}

class WatchListWidget extends StatefulWidget {
  const WatchListWidget({super.key});

  @override
  State<StatefulWidget> createState() => WatchListWidgetState();
}

class WatchListWidgetState extends State<WatchListWidget> {

  List<Watch> watches = <Watch>[];
  Map<String, Service> serviceMap = <String, Service>{};

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _handleRefresh() async {
    List<Watch> newWatches = await DbHive().getAll<Watch>();
    
    // TODO: find a way to get items with fks included
    Map<String, Service> newServiceMap = <String, Service>{};
    for (Watch w in newWatches) {
      Service? s = await DbHive().get<Service>(w.serviceId);
      newServiceMap[s!.id!] = s;
    }
    setState(() {
      watches = newWatches;
      serviceMap = newServiceMap;
    });
  }

  void _deleteWatch(Watch item) async {
    await DbHive().delete<Watch>(item.id!);
    watches.remove(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: watches.length,
      itemBuilder: (BuildContext context, int index) {
        return WatchListItem.fromWatch(watches[index], serviceMap[watches[index].serviceId]!.thumbnailUrl!, key: ObjectKey(watches[index]), onDeleteClicked: () => {_deleteWatch(watches[index])});
      },
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      }
    );
  }
}