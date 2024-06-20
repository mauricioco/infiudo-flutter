import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';

class PresetHelper {
  
  static final PresetHelper _presetHelper = PresetHelper._internal();

  PresetHelper._internal();

  factory PresetHelper() {
    return _presetHelper;
  }

  Future createDefaultService() async {

    DbHive().deleteAll<Service>();
    DbHive().deleteAll<Mapper>();
    DbHive().deleteAll<UIMapper>();

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