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
  String offsetKey;   // TODO: include jsonpath in name

  String resultsKey;  // TODO: include jsonpath in name
  String totalKey;    // TODO: include jsonpath in name

  int maximumResults;
  int offsetPerPage;

  String defaultMapperId;
  String defaultUIMapperId;

  String? thumbnailUrl;

  Service({
    super.id,
    required this.description,
    required this.urlBase,
    required this.type,
    required this.queryParamKey,
    required this.offsetKey,
    required this.resultsKey,
    required this.totalKey,
    required this.maximumResults,
    required this.offsetPerPage,
    required this.defaultMapperId,
    required this.defaultUIMapperId,
    this.thumbnailUrl
  });

  factory Service.fromJson(Map<dynamic, dynamic> json) => _$ServiceFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$ServiceToJson(this);

}
