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
    return _getFieldFromResult(r, leadingThumbnailUrl, null);
  }

  String getTitleFromResult(Result r) {
    return _getFieldFromResult(r, title, null);
  }

  String getSubtitleFromResult(Result r, DateTime? timestamp) {
    return _getFieldFromResult(r, subtitle, timestamp);
  }

  int getSubtitleComparisonFromResult(Result r, DateTime? timestamp) {
    return _getComparisonFromResult(r, subtitle, timestamp);
  }

  String getUrlFromResult(Result r) {
    return _getFieldFromResult(r, url, null);
  }

  // TODO null check
  String _getFieldFromResult(Result r, String field, DateTime? timestamp) {
    String text = r.currentData.data[field].toString();
    if (timestamp != null && r.currentData.timestamp.isAfter(timestamp) && r.snapshots.isNotEmpty) {
      text = '${r.snapshots.last.data[field].toString()} -> $text';
    }
    return text;
  }

  // TODO null check
  int _getComparisonFromResult(Result r, String field, DateTime? timestamp) {
    if (timestamp != null && r.currentData.timestamp.isAfter(timestamp) && r.snapshots.isNotEmpty) {
      if (r.snapshots.last.data[field] > r.currentData.data[field]) {
        return -1;
      } else if (r.snapshots.last.data[field] < r.currentData.data[field]) {
        return 1;
      }
    }
    return 0;
  }

  factory UIMapper.fromJson(Map<dynamic, dynamic> json) => _$UIMapperFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$UIMapperToJson(this);
}
