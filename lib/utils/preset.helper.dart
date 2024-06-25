import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/models/watch.dart';

class PresetHelper {
  
  static final PresetHelper _presetHelper = PresetHelper._internal();

  PresetHelper._internal();

  factory PresetHelper() {
    return _presetHelper;
  }

  Future updateAllResults() async {
    List<Watch> allWatches = await DbHive().getAll<Watch>();
    List<Result> allResults = <Result>[];

    List<Result> favorites = await DbHive().getAll<Result>(boxModifier: 'favorites');
    var favoriteMap = {};
    for (Result f in favorites) {
      favoriteMap[f.id] = f;
    }
    
    for (Watch w in allWatches) {
      var resultsInWatch = await DbHive().getAll<Result>(boxModifier: w.id);
      for (var r in resultsInWatch) {
        r.watchId = w.id!;
        r.favorite = favoriteMap.containsKey(r.id);
      }
      allResults.addAll(resultsInWatch);
    }
    
    for (Result r in allResults) {
      await DbHive().save(r, boxModifier: r.watchId);
    }
    
  }

  Future createDefaultService() async {

    //DbHive().deleteAll<Service>();
    //DbHive().deleteAll<Mapper>();
    //DbHive().deleteAll<UIMapper>();

    //await updateAllResults();

    final String presetUIMappersString = await rootBundle.loadString('assets/preset_ui_mappers.json');
    final String presetMappersString = await rootBundle.loadString('assets/preset_mappers.json');
    final String presetServicesString = await rootBundle.loadString('assets/preset_services.json');

    List presetUIMappers = jsonDecode(presetUIMappersString);
    List presetMappers = jsonDecode(presetMappersString);
    List presetServices = jsonDecode(presetServicesString);

    for (Map uiMapperJson in presetUIMappers) {
      UIMapper uiMapper = UIMapper.fromJson(uiMapperJson);
      await DbHive().save(uiMapper);
    }

    for (Map mapperJson in presetMappers) {
      Mapper mapper = Mapper.fromJson(mapperJson);
      await DbHive().save(mapper);
    }

    for (Map serviceJson in presetServices) {
      Service service = Service.fromJson(serviceJson);
      await DbHive().save(service);
    }

  }

}