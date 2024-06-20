// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mapper _$MapperFromJson(Map json) => Mapper(
      description: json['description'] as String,
      idJsonPath: json['idJsonPath'] as String,
      mappings: (json['mappings'] as List<dynamic>)
          .map((e) => FieldMapping.fromJson(e as Map))
          .toList(),
      compareMappings: (json['compareMappings'] as List<dynamic>)
          .map((e) => CompareMapping.fromJson(e as Map))
          .toList(),
    )
      ..id = json['id'] as String?;

Map<String, dynamic> _$MapperToJson(Mapper instance) => <String, dynamic>{
      'description': instance.description,
      'idJsonPath': instance.idJsonPath,
      'mappings': instance.mappings.map((e) => e.toJson()).toList(),
      'compareMappings': instance.compareMappings.map((e) => e.toJson()).toList()
    };

FieldMapping _$FieldMappingFromJson(Map json) => FieldMapping(
      from: json['from'] as String,
      to: json['to'] as String,
    )
      ..prepend = json['prepend'] as String?
      ..encode = json['encode'] as bool?;

Map<String, dynamic> _$FieldMappingToJson(FieldMapping instance) => <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'prepend': instance.prepend,
      'encode': instance.encode,
    };

CompareMapping _$CompareMappingFromJson(Map json) => CompareMapping(
      field: json['field'] as String,
      oldField: json['oldField'] as String,
      operator: $enumDecode(_$OperatorTypeEnumMap, json['operator']),
    );

Map<String, dynamic> _$CompareMappingToJson(CompareMapping instance) => <String, dynamic>{
      'field': instance.field,
      'oldField': instance.oldField,
      'operator': _$OperatorTypeEnumMap[instance.operator]!,
    };

const _$OperatorTypeEnumMap = {
  OperatorType.lt: 'lt',
  OperatorType.gt: 'gt',
};