// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map json) => Service(
      description: json['description'] as String,
      urlBase: json['urlBase'] as String,
      type: $enumDecode(_$ServiceTypeEnumMap, json['type']),
      queryParamKey: json['queryParamKey'] as String,
      offsetParamKey: json['offsetParamKey'] as String,
      maximumResults: json['maximumResults'] as int,
      defaultMapperId: json['defaultMapperId'] as String,
      defaultUIMapperId: json['defaultUIMapperId'] as String
    )
      ..id = json['id'] as String?
      ..thumbnailUrl = json['thumbnailUrl'] as String?;

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'urlBase': instance.urlBase,
      'description': instance.description,
      'type': _$ServiceTypeEnumMap[instance.type]!,
      'queryParamKey': instance.queryParamKey,
      'offsetParamKey': instance.offsetParamKey,
      'maximumResults': instance.maximumResults,
      'defaultMapperId': instance.defaultMapperId,
      'defaultUIMapperId': instance.defaultUIMapperId,
      'thumbnailUrl': instance.thumbnailUrl
    };

const _$ServiceTypeEnumMap = {
  ServiceType.json: 'json',
  ServiceType.jsonarray: 'jsonarray',
  ServiceType.html: 'html',
};
