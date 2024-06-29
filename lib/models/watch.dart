import 'package:json_annotation/json_annotation.dart';

import 'package:infiudo/models/model.dart';

part 'watch.g.dart';

@JsonSerializable(anyMap: true)
class Watch extends Model {

  String serviceId;

  String query;

  DateTime? lastWatch;
  
  String? mapperId;
  String? postMapperId;

  String? uiMapperId;
  
  Watch({
    super.id,
    required this.serviceId,
    required this.query,
    this.lastWatch,
    this.mapperId,
    this.postMapperId,
    this.uiMapperId,
  });

  factory Watch.fromJson(Map<dynamic, dynamic> json) => _$WatchFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => {...super.toJson(), ..._$WatchToJson(this)};

}