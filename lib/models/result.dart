import 'dart:core';

import 'package:json_annotation/json_annotation.dart';

import 'package:infiudo/models/model.dart';

part 'result.g.dart';

enum ResultType {json, jsonarray, html}

@JsonSerializable(anyMap: true)
class Result extends Model {

  String watchId;
  bool favorite;
  ResultData currentData;
  List<ResultData> snapshots;

  Result({
    super.id,
    required this.watchId,
    required this.favorite,
    required this.currentData,
    this.snapshots = const [],
  });
  
  // TODO this only works for single field comparison
  Result updateDataValue(String key, dynamic value) {
    if (currentData.data[key] != value) {
      snapshots.add(ResultData(timestamp: currentData.timestamp, data: {key: currentData.data[key]}));
      currentData.updateValue(key, value);
    }
    return this;
  }

  factory Result.fromJson(Map<dynamic, dynamic> json) => _$ResultFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$ResultToJson(this);

}

@JsonSerializable(anyMap: true)
class ResultData {
  DateTime timestamp;
  Map<dynamic, dynamic> data;
  
  ResultData({
    required this.timestamp,
    required this.data,
  });

  ResultData updateValue(String key, dynamic value) {
    data[key] = value;
    timestamp = DateTime.now();
    return this;
  }

  factory ResultData.fromJson(Map<dynamic, dynamic> json) => _$ResultDataFromJson(json);

  Map<dynamic, dynamic> toJson() => _$ResultDataToJson(this);

}