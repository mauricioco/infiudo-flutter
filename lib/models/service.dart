import 'package:infiudo/models/model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

enum ServiceType {json, jsonarray, html}

@JsonSerializable(anyMap: true)
class Service extends Model {
  String urlBase;
  String description;
  ServiceType type;

  String queryParamKey;
  String offsetParamKey;

  int maximumResults;   // Some services prevent paging beyond a certain amount

  String defaultMapperId;
  String defaultUIMapperId;

  String? thumbnailUrl;

  Service({
    super.id,
    required this.description,
    required this.urlBase,
    required this.type,
    required this.queryParamKey,
    required this.offsetParamKey,
    required this.maximumResults,
    required this.defaultMapperId,
    required this.defaultUIMapperId,
    this.thumbnailUrl
  });

  factory Service.fromJson(Map<dynamic, dynamic> json) => _$ServiceFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$ServiceToJson(this);

}
