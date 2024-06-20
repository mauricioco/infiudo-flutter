// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_mapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UIMapper _$UIMapperFromJson(Map json) => UIMapper(
      description: json['description'] as String,
      leadingThumbnailUrl: json['leadingThumbnailUrl'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      subtitleOld: json['subtitleOld'] as String,
      url: json['url'] as String,
    )
      ..id = json['id'] as String?;

Map<String, dynamic> _$UIMapperToJson(UIMapper instance) => <String, dynamic>{
      'description': instance.description,
      'leadingThumbnailUrl': instance.leadingThumbnailUrl,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'subtitleOld': instance.subtitleOld,
      'url': instance.url,
    };
