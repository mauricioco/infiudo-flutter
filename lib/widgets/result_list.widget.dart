import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/utils/api.helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultListItem extends StatefulWidget {
  
  final Result result;
  final UIMapper uiMapper;

  final bool favorite;
  
  const ResultListItem.fromResult(this.result, this.uiMapper, this.favorite, {super.key});

  String getId() {
    return result.id!;
  }

  String getThumbnailUrl() {
    return result.data[uiMapper.leadingThumbnailUrl];
  }

  String getTitle() {
    return result.data[uiMapper.title];
  }

  String getSubtitle() {
    var subtitle = result.data[uiMapper.subtitle];
    var subtitleOld = result.data[uiMapper.subtitleOld];
    if (subtitleOld != null) {
      if (subtitleOld == subtitle) {
        return subtitle.toString();
      } else {
        return '$subtitleOld -> $subtitle';
      }
    } else {
      return subtitle.toString();
    }
  }

  String getUrl() {
    return result.data[uiMapper.url];
  }

  @override
  State<ResultListItem> createState() => _ResultListItemState();
}

class _ResultListItemState extends State<ResultListItem> {
  bool favorite = false;

  Future<void> setFavorite() async {
    if (favorite) {
      await DbHive().delete<Result>(widget.result.id!, boxModifier: 'favorites');
    } else {
      await DbHive().save<Result>(widget.result, boxModifier: 'favorites');
    }
    setState(() {
      favorite = !favorite;
    });
  }

  @override void initState() {
    super.initState();
    favorite = widget.favorite;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Uri url = Uri.parse(widget.getUrl());
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
      child: SizedBox(
        height: 128,
          child: Center(
            child: ListTile(
              leading: Image.network(widget.getThumbnailUrl()),
              title: Text(widget.getTitle()),
              subtitle: Text(widget.getSubtitle()),
              trailing: IconButton(
                      onPressed: () async {
                        await setFavorite();
                      },
                      icon: favorite ? const Icon(Icons.star_rounded) : const Icon(Icons.star_border_rounded),
              ),
            ),
          ),
        ),
    );
  }
}

class ResultListWidget extends StatefulWidget {
  const ResultListWidget({super.key});

  @override
  State<StatefulWidget> createState() => ResultListWidgetState();
}

class ResultListWidgetState extends State<ResultListWidget> {

  List<Result> newResults = <Result>[];
  List<Result> favoriteResults = <Result>[];

  Map<String, Service> services = <String, Service>{};
  Map<String, UIMapper> uiMappers = <String, UIMapper>{};

  bool isLoading = false;

  @override void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    favoriteResults = await DbHive().getAll<Result>(boxModifier: 'favorites');
    for (Result r in favoriteResults) {
      if (!services.containsKey(r.serviceId)) {
        services[r.serviceId] = (await DbHive().get<Service>(r.serviceId))!;
        uiMappers[r.serviceId] = (await DbHive().get<UIMapper>(services[r.serviceId]!.defaultUIMapperId))!;
      }
    }
    setState(() {});
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    List<Result> newIn = await ApiHelper().watchAll();
    List<Result> favorites = await DbHive().getAll<Result>(boxModifier: 'favorites');

    for (Result r in newIn) {
      if (!services.containsKey(r.serviceId)) {
        services[r.serviceId] = (await DbHive().get<Service>(r.serviceId))!;
        uiMappers[r.serviceId] = (await DbHive().get<UIMapper>(services[r.serviceId]!.defaultUIMapperId))!;
      }
    }

    setState(() {
      newResults = newIn;
      favoriteResults = favorites;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ScrollConfiguration(   // Hack to allow "pull to refresh" on windows
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.separated(
              
              itemCount: newResults.length + favoriteResults.length,
              itemBuilder: (BuildContext context, int index) {
                if (index < newResults.length) {
                  return ResultListItem.fromResult(newResults[index], uiMappers[newResults[index].serviceId]!, false, key: ObjectKey(newResults[index]));
                } else {
                  return ResultListItem.fromResult(favoriteResults[index-newResults.length], uiMappers[favoriteResults[index-newResults.length].serviceId]!, true, key: ObjectKey(favoriteResults[index-newResults.length]));
                }
              },
              separatorBuilder: (context, index) {
                return const Divider(height: 1);
              },
            ),
          ),
        ),
        if (isLoading)
        // TODO improve this loading animation!
          const Opacity(
            opacity: 0.5,
            child: ModalBarrier(dismissible: false, color: Colors.black)
        )
      ]
    );
  }
}