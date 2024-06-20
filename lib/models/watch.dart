import 'package:json_annotation/json_annotation.dart';

import 'package:infiudo/models/model.dart';

part 'watch.g.dart';

@JsonSerializable(anyMap: true)
class Watch extends Model {

  String serviceId;

  String query;
  
  String? mapperId;
  String? postMapperId;
  
  Watch({
    super.id,
    required this.serviceId,
    required this.query,
    this.mapperId,
    this.postMapperId
  });

  factory Watch.fromJson(Map<dynamic, dynamic> json) => _$WatchFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$WatchToJson(this);

}