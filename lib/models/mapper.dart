import 'package:infiudo/models/model.dart';
import 'package:infiudo/models/result.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_by_path/json_by_path.dart';

part 'mapper.g.dart';

@JsonSerializable(anyMap: true)
class Mapper extends Model {

  static final JsonByPath jbp = JsonByPath();

  String description;

  // jsonarray properties
  String resultListJsonPath;
  String offsetJsonPath;
  String limitPerPageJsonPath;
  String totalJsonPath;
  
  // universal properties
  String idJsonPath;

  List<FieldMapping> mappings;
  List<CompareMapping> compareMappings;
  
  Mapper({
    super.id,
    required this.description,
    required this.resultListJsonPath,
    required this.offsetJsonPath,
    required this.limitPerPageJsonPath,
    required this.totalJsonPath,
    required this.idJsonPath,
    required this.mappings,
    required this.compareMappings,
  });

  dynamic mapResultArray(Map<String, dynamic> json) {
    return jbp.getValue(json, resultListJsonPath);
  }

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

  Map<String, dynamic> compareData(Result r, Map<String, dynamic> newData) {
    //Map<String, dynamic> newData = {...data};
    Map<String, dynamic> changedData = <String, dynamic>{};
    
    for (CompareMapping c in compareMappings) {
      if (r.currentData.data[c.field] != newData[c.field]) {
        changedData[c.field] = newData[c.field];
      }
    }

    return changedData;
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
  OperatorType operator;  // ignored for now

  CompareMapping({
    required this.field,
    required this.operator
  });

  factory CompareMapping.fromJson(Map<dynamic, dynamic> json) => _$CompareMappingFromJson(json);

  Map<dynamic, dynamic> toJson() => _$CompareMappingToJson(this);

}