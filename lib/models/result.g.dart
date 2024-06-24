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
      ..lastModified = json['lastModified'] as DateTime?;

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'serviceId': instance.serviceId,
      'data': instance.data,
      'lastModified': instance.lastModified,
    };
