import 'package:json_annotation/json_annotation.dart';

import 'package:infiudo/models/model.dart';

part 'result.g.dart';

enum ResultType {json, jsonarray, html}

@JsonSerializable(anyMap: true)
class Result extends Model {
  String serviceId;
  Map<dynamic, dynamic> data;
  
  Result({
    super.id,
    required this.serviceId,
    required this.data,
  });

  factory Result.fromJson(Map<dynamic, dynamic> json) => _$ResultFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$ResultToJson(this);

}