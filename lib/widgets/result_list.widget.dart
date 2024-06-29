import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infiudo/app_state.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/models/watch.dart';
import 'package:infiudo/utils/api.helper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultListItem extends StatefulWidget {
  
  final Result result;
  final DateTime lastWatch;
  final UIMapper? uiMapper;
  
  // TODO check if Watch could be the timestamp only
  const ResultListItem.fromResult(this.result, this.lastWatch, this.uiMapper, {super.key});

  String getId() {
    return result.id!;
  }

  String? getThumbnailUrl() {
    return uiMapper?.getThumbnailFromResult(result);
  }

  String? getTitle() {
    return uiMapper?.getTitleFromResult(result);
  }

  String? getSubtitle() {
    return uiMapper?.getSubtitleFromResult(result, lastWatch);
    /*
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
    */
  }

  String? getUrl() {
    return uiMapper?.getUrlFromResult(result);
  }

  @override
  State<ResultListItem> createState() => _ResultListItemState();
}

class _ResultListItemState extends State<ResultListItem> {

  @override void initState() {
    super.initState();
  }

  Future<void> setFavorite() async {
    widget.result.favorite = !widget.result.favorite;
    await ApiHelper().updateResult(widget.result);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Uri url = Uri.parse(widget.getUrl() ?? 'about:blank');
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
      child: SizedBox(
        height: 128,
          child: Center(
            child: ListTile(
              leading: SizedBox(
                width: 64,
                child: Image.network(widget.getThumbnailUrl() ?? 'http://placehold.jp/150x150.png', fit: BoxFit.contain),
              ),
              title: Text(
                widget.getTitle() ?? 'DELETED WATCH',
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                ),
              subtitle: Text(widget.getSubtitle() ?? 'DELETED WATCH'),
              trailing: IconButton(
                      onPressed: () async {
                        await setFavorite();
                      },
                      icon: widget.result.favorite ? const Icon(Icons.star_rounded) : const Icon(Icons.star_border_rounded),
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
  
  @override void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    newResults = await ApiHelper().getAllCurrentResults();

    // Filter repeating results
    Map<String, Result> newUniqueResults = {};
    for(Result r in newResults) { newUniqueResults[r.id!] = r; }
    newResults = newUniqueResults.values.toList();

    setState(() {});
  }

  Future<void> _handleRefresh() async {
    
    setState(() {
      Provider.of<AppState>(context, listen: false).isLoading = true;
    });

    await ApiHelper().watchAll(context);
    List<Result> currentResults = await ApiHelper().getAllCurrentResults();

    setState(() {
      newResults = currentResults;
      Provider.of<AppState>(context, listen: false).isLoading = false;
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
              itemCount: newResults.length,
              itemBuilder: (BuildContext context, int index) {
                Watch? w = ApiHelper().getCachedWatchForResult(newResults[index]);  // This needs to return something
                return ResultListItem.fromResult(newResults[index], 
                  w?.lastWatch != null ? w!.lastWatch! : newResults[index].currentData.timestamp, 
                  ApiHelper().getCachedUIMapperForResult(newResults[index]), 
                  key: ObjectKey(newResults[index]));
              },
              separatorBuilder: (context, index) {
                return const Divider(height: 1);
              },
            ),
          ),
        ),
      ]
    );
  }
}