// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(Map json) => Result(
      serviceId: json['serviceId'] as String,
      data: json['data'] as Map,
    )
      ..id = json['id'] as String?
      ..lastModified = json['lastModified'] as DateTime?
      ..favorite = json['favorite'] as bool?
      ..watchId = json['watchId'] as String?;

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'serviceId': instance.serviceId,
      'watchId': instance.watchId,
      'favorite': instance.favorite,
      'lastModified': instance.lastModified,
      'data': instance.data,
    };
