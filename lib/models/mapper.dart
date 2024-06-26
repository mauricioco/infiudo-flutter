import 'package:infiudo/models/model.dart';
import 'package:infiudo/models/result.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_by_path/json_by_path.dart';

part 'mapper.g.dart';

@JsonSerializable(anyMap: true)
class Mapper extends Model {

  static final JsonByPath jbp = JsonByPath();

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

  String mapId(Map<String, dynamic> jsonObj) {
    return jbp.getValue(jsonObj, idJsonPath);
  }

  Map<String, dynamic> mapObject(Map<String, dynamic> jsonObj) {
    Map<String, dynamic> mappedObj = {};
    for (FieldMapping mppng in mappings) {
      var value = jbp.getValue(jsonObj, mppng.from);
      jbp.setValue(mappedObj, mppng.to, value);
    }
    return mappedObj;
  }

  // TODO this only works for single field comparison
  bool compareUpdatingSingleData(Map<String, dynamic> newData, Result r) {
    //Map<String, dynamic> newData = {...data};
    bool hasChanged = false;
    for (CompareMapping c in compareMappings) {
      switch(c.operator) {
        case OperatorType.lt:
          if (newData[c.field] < r.currentData.data[c.field]) {
            r.updateSingleDataValue(c.field, newData[c.field]);
            hasChanged = true;
          }
          break;
        case OperatorType.gt:
          if (newData[c.field] > r.currentData.data[c.field]) {
            r.updateSingleDataValue(c.field, newData[c.field]);
            hasChanged = true;
          }
          break;
        default:
          break;
      }
    }
    return hasChanged;
  }

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