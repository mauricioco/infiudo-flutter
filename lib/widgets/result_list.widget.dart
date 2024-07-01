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
  final Watch watch;
  final UIMapper? uiMapper;
  
  const ResultListItem.fromResult(this.result, this.watch, this.uiMapper, {super.key});

  get id {
    return result.id!;
  }

  get thumbnailUrl {
    return uiMapper?.getThumbnailFromResult(result);
  }

  get title {
    return uiMapper?.getTitleFromResult(result);
  }

  get subtitle {
    return uiMapper?.getSubtitleFromResult(result, watch.lastWatch ?? result.currentData.timestamp);
  }

  get subtitleStyle {
    switch (uiMapper?.getSubtitleComparisonFromResult(result, watch.lastWatch ?? result.currentData.timestamp)) {
      case 1:
        return const TextStyle(color: Colors.red);
      case -1:
        return const TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
      default:
        return const TextStyle();
    }
  }

  get url {
    return uiMapper?.getUrlFromResult(result);
  }

  get watchQuery {
    return Uri.decodeComponent(watch.query);
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
        final Uri url = Uri.parse(widget.url ?? 'about:blank');
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
      onLongPress: () {
        showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Watch info'),
            content: Text(widget.watchQuery),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK')),
            ],
          );
        });
      },
      child: SizedBox(
        height: 128,
          child: Center(
            child: ListTile(
              leading: SizedBox(
                width: 64,
                child: Image.network(widget.thumbnailUrl ?? 'http://placehold.jp/150x150.png', fit: BoxFit.contain),
              ),
              title: Text(
                widget.title ?? 'DELETED WATCH',
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                ),
              subtitle: Text(widget.subtitle ?? 'DELETED WATCH',
                style: widget.subtitleStyle,              
              ),
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
                final Watch? w = ApiHelper().getCachedWatchForResult(newResults[index]);  // This needs to return something
                return ResultListItem.fromResult(newResults[index], w!, ApiHelper().getCachedUIMapperForResult(newResults[index]), key: ObjectKey(newResults[index]));
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