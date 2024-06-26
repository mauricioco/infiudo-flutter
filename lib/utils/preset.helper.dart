import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
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

    if (deletedAllResults != null && !deletedAllResults) {
      await ApiHelper().deleteAllResults();
      await prefs.setBool('deleted_all_results', true);
    }
  }

  Future createDefaultService() async {

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