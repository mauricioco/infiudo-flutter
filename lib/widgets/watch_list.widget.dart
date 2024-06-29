import 'package:flutter/material.dart';

import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/watch.dart';
import 'package:infiudo/utils/api.helper.dart';
import 'package:infiudo/utils/cache.helper.dart';

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
  final ScrollController hideButtonController;

  const WatchListWidget({
    Key? key,
    required this.hideButtonController,
  }) : super(key: key);

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
    List<Watch> newWatches = CacheHelper().getCachedWatches().where((w) => !w.deleted!).toList();
    
    // TODO: find a way to get items with fks included
    Map<String, Service> newServiceMap = <String, Service>{};
    for (Watch w in newWatches) {
      Service s = CacheHelper().getCached<Service>(w.serviceId)!;
      newServiceMap[s.id!] = s;
    }
    setState(() {
      watches = newWatches;
      serviceMap = newServiceMap;
    });
  }

  void _deleteWatch(Watch item) async {
    await ApiHelper().deleteLogicalWatch(item);
    watches.remove(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: widget.hideButtonController,
      itemCount: watches.length,
      itemBuilder: (BuildContext context, int i) {
        return WatchListItem.fromWatch(watches[i], CacheHelper().getCached<Service>(watches[i].serviceId)!.thumbnailUrl!, key: ObjectKey(watches[i]), onDeleteClicked: () => {_deleteWatch(watches[i])});
      },
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      }
    );
  }
}