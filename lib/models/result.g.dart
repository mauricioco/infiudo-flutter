// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(Map json) => Result(
      watchId: json['watchId'] as String,
      favorite: json['favorite'] as bool,
      data: json['data'] as Map,
    )
      ..id = json['id'] as String?
      ..lastModified = json['lastModified'] as DateTime?;

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'watchId': instance.watchId,
      'favorite': instance.favorite,
      'lastModified': instance.lastModified,
      'data': instance.data,
    };
