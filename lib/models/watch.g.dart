// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Watch _$WatchFromJson(Map json) => Watch(
      serviceId: json['serviceId'] as String,
      query: json['query'] as String,
      lastWatch: json['lastWatch'] as DateTime?,
      mapperId: json['mapperId'] as String?,
      postMapperId: json['postMapperId'] as String?,
      uiMapperId: json['uiMapperId'] as String?
    );

Map<String, dynamic> _$WatchToJson(Watch instance) => <String, dynamic>{
      'serviceId': instance.serviceId,
      'query': instance.query,
      'lastWatch': instance.lastWatch,
      'mapperId': instance.mapperId,
      'postMapperId': instance.postMapperId,
      'uiMapperId': instance.uiMapperId,
    };
