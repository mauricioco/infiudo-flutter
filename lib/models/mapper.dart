import 'package:infiudo/models/model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mapper.g.dart';

@JsonSerializable(anyMap: true)
class Mapper extends Model {
  String description;
  String idJsonPath;

  List<FieldMapping> mappings;
  List<CompareMapping> compareMappings;
  
  Mapper({
    super.id,
    required this.description,
    required this.idJsonPath,
    required this.mappings,
    required this.compareMappings,
  });

  factory Mapper.fromJson(Map<dynamic, dynamic> json) => _$MapperFromJson(json);

  @override
  Map<dynamic, dynamic> toJson() => _$MapperToJson(this);
}

@JsonSerializable(anyMap: true)
class FieldMapping {
  String from;
  String to;

  String? prepend;
  bool? encode;

  FieldMapping({
    required this.from,
    required this.to
  });

  factory FieldMapping.fromJson(Map<dynamic, dynamic> json) => _$FieldMappingFromJson(json);

  Map<dynamic, dynamic> toJson() => _$FieldMappingToJson(this);

}

enum OperatorType {lt, gt}

@JsonSerializable(anyMap: true)
class CompareMapping {
  String field;
  OperatorType operator;

  CompareMapping({
    required this.field,
    required this.operator
  });

  factory CompareMapping.fromJson(Map<dynamic, dynamic> json) => _$CompareMappingFromJson(json);

  Map<dynamic, dynamic> toJson() => _$CompareMappingToJson(this);

}