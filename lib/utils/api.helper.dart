
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:json_by_path/json_by_path.dart';

import '../models/watch.dart';

class ApiHelper {
  
  static final ApiHelper _apiHelper = ApiHelper._internal();

  ApiHelper._internal();

  factory ApiHelper() {
    return _apiHelper;
  }

  // TODO: change way to save favorites so it's not saving duplicates
  Future<Result> saveFavorite(Result result) async {
    return await DbHive().save(result, boxModifier: 'favorites');
  }

  Future<Result?> removeFavorite(Result result) async {
    return await DbHive().delete<Result>(result.id!, boxModifier: 'favorites');
  }

  Future<List<Result>> watchAll() async {
    List<Watch> allWatches = await DbHive().getAll<Watch>();
    List<Result> newResults = <Result>[];
    for (Watch w in allWatches) {
      newResults.addAll(await watch(w));
    }
    return newResults;
  }

  Future<List<Result>> watch(Watch w) async {
    Service? srv = await DbHive().get<Service>(w.serviceId);
    srv!;
    Mapper? mppr = await DbHive().get<Mapper>(srv.defaultMapperId);
    mppr!;
    List<Result> favorites = await DbHive().getAll<Result>(boxModifier: 'favorites');
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
            newResults.add(Result(id: itemId, serviceId: srv.id!, data: mappedObj));
          } else {
            bool hasChanged = false;
            for (CompareMapping c in mppr.compareMappings) {
              switch(c.operator) {
                case OperatorType.lt:
                  if (mappedObj[c.field] < existingResult.data[c.field]) {
                    hasChanged = true;
                    existingResult.data[c.oldField] = existingResult.data[c.field];
                    existingResult.data[c.field] = mappedObj[c.field];
                  } else {
                    if (existingResult.data[c.field] != existingResult.data[c.oldField]) {
                      existingResult.data[c.oldField] = existingResult.data[c.field];
                    }
                  }
                  break;
                case OperatorType.gt:
                  if (mappedObj[c.field] > existingResult.data[c.field]) {
                    hasChanged = true;
                    existingResult.data[c.oldField] = existingResult.data[c.field];
                    existingResult.data[c.field] = mappedObj[c.field];
                  } else {
                    if (existingResult.data[c.field] != existingResult.data[c.oldField]) {
                      existingResult.data[c.oldField] = existingResult.data[c.field];
                    }
                  }
                  break;
                default:
                  break;
              }
            }

            if (hasChanged) {
              newResults.add(existingResult);
            }
            if (favorites.any((item) => item.id == itemId)) {
              await saveFavorite(existingResult);
            }
          }
        }
        totalValue = jbp.getValue<int>(json, srv.totalKey)!;
        currOffset += srv.offsetPerPage;   //TODO offsetperpage should be jsnonpath to "limit"
        url = '${srv.urlBase}?${srv.queryParamKey}=${w.query}&${srv.offsetKey}=$currOffset';
        print('next: $url');
      } else {
        throw Exception('Failed to load request');
      }
    } while (currOffset < totalValue && currOffset < srv.maximumResults);
    DbHive().saveAll<Result>(newResults, boxModifier: w.id);
    return newResults;
  }

}