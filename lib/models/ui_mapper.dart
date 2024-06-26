// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:infiudo/models/result.dart';
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
  String url;

  UIMapper({
    required this.description,
    required this.leadingThumbnailUrl,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  String getThumbnailFromResult(Result r) {
    return _getFieldFromResult(r, leadingThumbnailUrl, false);
  }

  String getTitleFromResult(Result r) {
    return _getFieldFromResult(r, title, false);
  }

  String getSubtitleFromResult(Result r) {
    return _getFieldFromResult(r, subtitle, true);
  }
  
  String getUrlFromResult(Result r) {
    return _getFieldFromResult(r, url, false);
  }

  // TODO null check
  String _getFieldFromResult(Result r, String field, bool checkHistory) {
    String text = r.currentData.data[field].toString();
    if (checkHistory && r.snapshots.isNotEmpty) {
      text = '${r.snapshots.last.data[field].toString()} -> $text';
    }
    return text;
  }

  factory UIMapper.fromJson(Map<dynamic, dynamic> json) => _$UIMapperFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$UIMapperToJson(this);
}
