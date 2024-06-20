// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

import 'package:infiudo/models/model.dart';

part 'ui_mapper.g.dart';

// TODO: only made for list tile for now
@JsonSerializable(anyMap: true)
class UIMapper extends Model {
  String description;
  String leadingThumbnailUrl;
  String title;
  String subtitle;
  String subtitleOld;
  String url;

  UIMapper({
    required this.description,
    required this.leadingThumbnailUrl,
    required this.title,
    required this.subtitle,
    required this.subtitleOld,
    required this.url,
  });

  factory UIMapper.fromJson(Map<dynamic, dynamic> json) => _$UIMapperFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$UIMapperToJson(this);
}
