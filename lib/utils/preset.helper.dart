import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/model.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/models/watch.dart';
import 'package:infiudo/utils/api.helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresetHelper {
  
  static final PresetHelper _presetHelper = PresetHelper._internal();

  PresetHelper._internal();

  factory PresetHelper() {
    return _presetHelper;
  }

  Future deleteAllOldResults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? deletedAllResults = prefs.getBool('deleted_all_results');

    if (deletedAllResults == null || !deletedAllResults) {
      await ApiHelper().deleteAllResults();
      await prefs.setBool('deleted_all_results', true);
    }
  }

  Future saveFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedFavorites = prefs.getStringList('saved_favorites');

    if (savedFavorites == null) {
      savedFavorites = [];
      List<Watch> allWatches = await DbHive().getAll<Watch>();
      for (Watch w in allWatches) {
        for (var r in await DbHive().getAllGeneric<Result>(boxModifier: w.id)) {
          if(r!['favorite']) {
            savedFavorites.add(r['id']);
          }
        }
      }
      await prefs.setStringList('saved_favorites', savedFavorites);
    }
  }

  Future<List<String>> getSavedFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedFavorites = prefs.getStringList('saved_favorites');

    if (savedFavorites != null && savedFavorites.isNotEmpty) {
      await prefs.setStringList('saved_favorites', const []);
      return savedFavorites;
    }
    return const [];
  }

  Future createDefaultService() async {

    final String presetUIMappersString = await rootBundle.loadString('assets/preset_ui_mappers.json');
    final String presetMappersString = await rootBundle.loadString('assets/preset_mappers.json');
    final String presetServicesString = await rootBundle.loadString('assets/preset_services.json');

    List presetUIMappers = jsonDecode(presetUIMappersString);
    List presetMappers = jsonDecode(presetMappersString);
    List presetServices = jsonDecode(presetServicesString);

    for (Map uiMapperJson in presetUIMappers) {
      UIMapper uiMapper = Model.fromJson<UIMapper>(uiMapperJson['id'], uiMapperJson);
      await DbHive().save(uiMapper);
    }

    for (Map mapperJson in presetMappers) {
      Mapper mapper = Model.fromJson<Mapper>(mapperJson['id'], mapperJson);
      await DbHive().save(mapper);
    }

    for (Map serviceJson in presetServices) {
      Service service = Model.fromJson<Service>(serviceJson['id'], serviceJson);
      await DbHive().save(service);
    }

  }

}