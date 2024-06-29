
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:infiudo/app_state.dart';
import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/utils/cache.helper.dart';
import 'package:infiudo/utils/preset.helper.dart';
import 'package:json_by_path/json_by_path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/watch.dart';

class ApiHelper {
  
  static final ApiHelper _apiHelper = ApiHelper._internal();

  ApiHelper._internal();

  factory ApiHelper() {
    return _apiHelper;
  }

  Future<Watch> deleteLogicalWatch(Watch w) async {
    return CacheHelper().deleteCached<Watch>(await DbHive().deleteLogical(w));
  }


  UIMapper? getCachedUIMapperForResult(Result r) {
    final Watch? w = CacheHelper().getCached<Watch>(r.watchId);
    if (w == null) return null;

    final String? umid = w.uiMapperId ?? CacheHelper().getCached<Service>(w.serviceId)?.defaultUIMapperId;
    if (umid == null) return null;

    return CacheHelper().getCached<UIMapper>(umid);
  }

  Watch? getCachedWatchForResult(Result r) {
    return CacheHelper().getCached<Watch>(r.watchId);
  }

  Future<Result> updateResult(Result r) async {
    return await DbHive().save<Result>(r, boxModifier: r.watchId);
  }

  Future<List<Result>> getAllResults() async {
    List<Result> results = <Result>[];
    for (Watch w in CacheHelper().getCachedWatches()) {
      results.addAll(await DbHive().getAll<Result>(boxModifier: w.id));
    }
    return results;
  }

  Future<List<Result>> deleteAllResults() async {
    List<Result> results = <Result>[];
    for (Watch w in CacheHelper().getCachedWatches()) {
      await DbHive().deleteAll<Result>(boxModifier: w.id);
    }
    return results;
  }

  Future<List<Result>> getAllCurrentResults() async {
    List<Result> currentResults = <Result>[];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? lastWatchDateMillis = prefs.getInt('last_watch_date');
    DateTime lastWatchDate = lastWatchDateMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(lastWatchDateMillis);
    for (Watch w in CacheHelper().getCachedWatches()) {
      if (w.lastWatch != null) {
        currentResults.addAll(await DbHive().getWhere<Result>((K, element) => element.favorite || element.currentData.timestamp.compareTo(lastWatchDate) >= 0, boxModifier: w.id));
      }
    }
    // Favorites last
    currentResults.sort((a, b) {
      if (b.favorite) return -1;
      if (a.favorite) return 1;
      return 0;
    } );
    return currentResults;
  }

  Future<Watch> saveWatch(Watch w) async {
    Watch newWatch = await DbHive().save(w);
    CacheHelper().updateCached(newWatch);
    return newWatch;
  }

  Future<List<Result>> watchAll(BuildContext context) async {
    List<Result> newResults = <Result>[];
    DateTime now = DateTime.now();
    for (Watch w in CacheHelper().getCachedWatches()) {
      if (w.deleted!) {
        continue;
      }
      // ignore: use_build_context_synchronously
      newResults.addAll(await watch(w, now, context));
      w.lastWatch = now;
      await saveWatch(w);
    }
    // Temporary fix to keep favorites from previous version
    List<String> favoriteIds = await PresetHelper().getSavedFavorites();
    for (Result r in newResults) {
      if (favoriteIds.contains(r.id)) {
        r.favorite = true;
        await DbHive().save(r, boxModifier: r.watchId);
      }
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_watch_date', now.millisecondsSinceEpoch);
    return newResults;
  }

  Future<List<Result>> watch(Watch w, DateTime watchDate, BuildContext context) async {
    Service? srv = await DbHive().get<Service>(w.serviceId);
    srv!;
    Mapper? mppr = await DbHive().get<Mapper>(srv.defaultMapperId);
    mppr!;
    var currOffset = 0, totalValue = 0, newResults = <Result>[];
    String url = '${srv.urlBase}?${srv.queryParamKey}=${w.query}&${srv.offsetParamKey}=$currOffset';
    JsonByPath jbp = JsonByPath();
    do {
      await Future.delayed(const Duration(seconds:1));
      final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'utf-8'});
      if (response.statusCode == 200) {
        var json = jsonDecode(utf8.decode(response.bodyBytes));
        var results = mppr.mapResultArray(json);
        for (var r in results) {
          String itemId = mppr.mapId(r);
          Map<String, dynamic> mappedObj = mppr.mapObject(r);
          Result? existingResult = await DbHive().get<Result>(itemId, boxModifier: w.id);
          if (existingResult == null) {
            // Result is completely new
            newResults.add(Result(id: itemId, watchId: w.id!, favorite: false, currentData: ResultData(timestamp: watchDate, data: mappedObj)));
          } else {
            // Result already exists - check if it has been updated
            if (mppr.compareUpdatingSingleData(mappedObj, existingResult)) {
              newResults.add(existingResult);
            }
          }
        }
        totalValue = jbp.getValue<int>(json, mppr.totalJsonPath)!;
        currOffset += jbp.getValue<int>(json, mppr.limitPerPageJsonPath)!;
        // ignore: use_build_context_synchronously
        Provider.of<AppState>(context, listen: false).appendLog('${srv.urlBase}?${srv.queryParamKey}=${w.query}&${srv.offsetParamKey}=$currOffset');
        print('${srv.urlBase}?${srv.queryParamKey}=${w.query}&${srv.offsetParamKey}=$currOffset');
      } else {
        throw Exception('Failed to load request');
      }
    } while (currOffset < totalValue && currOffset < srv.maximumResults);
    DbHive().saveAll<Result>(newResults, boxModifier: w.id);
    return newResults;
  }

}