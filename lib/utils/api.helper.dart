
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:infiudo/app_state.dart';
import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/model.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:json_by_path/json_by_path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/watch.dart';

class ApiHelper {
  
  static final ApiHelper _apiHelper = ApiHelper._internal();

  ApiHelper._internal();

  final Map<String, Service> _serviceCache = {};
  final Map<String, Watch> _watchCache = {};
  final Map<String, Mapper> _mapperCache = {};
  final Map<String, UIMapper> _uiMapperCache = {};

  factory ApiHelper() {
    return _apiHelper;
  }

  Future<void> updateCache() async {
    for (var s in (await DbHive().getAll<Service>())) { _serviceCache[s.id!] = s; }
    for (var w in (await DbHive().getAll<Watch>())) { _watchCache[w.id!] = w; }
    for (var m in (await DbHive().getAll<Mapper>())) { _mapperCache[m.id!] = m; }
    for (var um in (await DbHive().getAll<UIMapper>())) { _uiMapperCache[um.id!] = um; }
  }

  Future<T?> _getCached<T extends Model>(String id) async {
    T? item = await DbHive().get<T>(id);
    switch(T) {
      case Service:
        _serviceCache[id] = item as Service;
      case Mapper:
        _mapperCache[id] = item as Mapper;
      case UIMapper:
        _uiMapperCache[id] = item as UIMapper;
      case Watch:
        _watchCache[id] = item as Watch;
      default:
        throw UnimplementedError();
    }
    return item;
  }

  // TODO check for null items from dbhive
  Future<UIMapper> getUIMapperForResult(Result r) async {
    Watch? w = _watchCache[r.watchId];
    w ??= await _getCached<Watch>(r.watchId);
    Service? s = _serviceCache[w?.serviceId];
    s ??= await _getCached<Service>(w!.serviceId);
    UIMapper? um = _uiMapperCache[s?.defaultUIMapperId];
    um ??= await _getCached<UIMapper>(s!.defaultUIMapperId);
    return um!;   
  }

  UIMapper? getCachedUIMapperForResult(Result r) {
    Watch? w = _watchCache[r.watchId];
    Service? s = _serviceCache[w?.serviceId];
    UIMapper? um = _uiMapperCache[s?.defaultUIMapperId];
    return um!;
  }

  Future<List<Result>> getAllResults() async {
    List<Watch> allWatches = await DbHive().getAll<Watch>();
    List<Result> results = <Result>[];
    for (Watch w in allWatches) {
      results.addAll(await DbHive().getAll<Result>(boxModifier: w.id));
    }
    return results;
  }

  Future<List<Result>> deleteAllResults() async {
    List<Watch> allWatches = await DbHive().getAll<Watch>();
    List<Result> results = <Result>[];
    for (Watch w in allWatches) {
      await DbHive().deleteAll<Result>(boxModifier: w.id);
    }
    return results;
  }

  Future<List<Result>> getAllCurrentResults() async {
    List<Watch> allWatches = await DbHive().getAll<Watch>();
    List<Result> currentResults = <Result>[];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? lastWatchDateMillis = prefs.getInt('last_watch_date');
    DateTime lastWatchDate = lastWatchDateMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(lastWatchDateMillis);
    for (Watch w in allWatches) {
      currentResults.addAll(await DbHive().getWhere<Result>((K, element) {
          return element.favorite || element.currentData.timestamp.compareTo(lastWatchDate) >= 0;
      }, boxModifier: w.id));
    }
    currentResults.sort((a, b) {
      if (b.favorite) return -1;
      if (a.favorite) return 1;
      return 0;
    } );
    return currentResults;
  }

  Future<List<Result>> watchAll(BuildContext context) async {
    List<Watch> allWatches = await DbHive().getAll<Watch>();
    List<Result> newResults = <Result>[];
    DateTime now = DateTime.now();
    for (Watch w in allWatches) {
      // ignore: use_build_context_synchronously
      newResults.addAll(await watch(w, now, context));
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
    String url = '${srv.urlBase}?${srv.queryParamKey}=${w.query}&${srv.offsetKey}=$currOffset';
    JsonByPath jbp = JsonByPath();
    do {
      await Future.delayed(const Duration(seconds:1));
      final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'utf-8'});
      if (response.statusCode == 200) {
        var json = jsonDecode(utf8.decode(response.bodyBytes));
        var results = jbp.getValue(json, srv.resultsKey);
        for (var r in results) {
          Map<String, dynamic> mappedObj = {};
          var itemId = jbp.getValue(r, mppr.idJsonPath);
          for (FieldMapping mppng in mppr.mappings) {
            var value = jbp.getValue(r, mppng.from);
            jbp.setValue(mappedObj, mppng.to, value);
          }
          Result? existingResult = await DbHive().get<Result>(itemId, boxModifier: w.id);
          if (existingResult == null) {
            // Result is completely new
            newResults.add(Result(id: itemId, watchId: w.id!, favorite: false, currentData: ResultData(timestamp: watchDate, data: mappedObj)));
          } else {
            // Result already exists - check if it has been updated
            bool hasChanged = false;

            // TODO put this logic inside Mapper
            for (CompareMapping c in mppr.compareMappings) {
              switch(c.operator) {
                case OperatorType.lt:
                  if (mappedObj[c.field] < existingResult.currentData.data[c.field]) {
                    existingResult.updateDataValue(c.field, mappedObj[c.field]);
                    hasChanged = true;
                  }
                  break;
                case OperatorType.gt:
                  if (mappedObj[c.field] > existingResult.currentData.data[c.field]) {
                    existingResult.updateDataValue(c.field, mappedObj[c.field]);
                    hasChanged = true;
                  }
                  break;
                default:
                  break;
              }
            }

            if (hasChanged) {
              newResults.add(existingResult);
            }
          }
        }
        totalValue = jbp.getValue<int>(json, srv.totalKey)!;
        currOffset += srv.offsetPerPage;   //TODO offsetperpage should be jsnonpath to "limit"
        // ignore: use_build_context_synchronously
        Provider.of<AppState>(context, listen: false).appendLog('${srv.urlBase}?${srv.queryParamKey}=${w.query}&${srv.offsetKey}=$currOffset');
        print('${srv.urlBase}?${srv.queryParamKey}=${w.query}&${srv.offsetKey}=$currOffset');
      } else {
        throw Exception('Failed to load request');
      }
    } while (currOffset < totalValue && currOffset < srv.maximumResults);
    DbHive().saveAll<Result>(newResults, boxModifier: w.id);
    return newResults;
  }

}