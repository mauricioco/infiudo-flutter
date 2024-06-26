import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/models/watch.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

abstract class Model {

  @JsonKey(includeFromJson: true, includeToJson: false)
  String? id;
  
  bool? deleted;

  Model({
    this.id, 
    this.deleted = false
  });

  static T fromJson<T extends Model>(String objId, Map<dynamic, dynamic> json) {
    T obj;
    switch(T) {
      case Service:
        obj = Service.fromJson(json) as T;
      case Mapper:
        obj =  Mapper.fromJson(json) as T;
      case UIMapper:
        obj =  UIMapper.fromJson(json) as T;
      case Result:
        obj =  Result.fromJson(json) as T;
      case Watch:
        obj =  Watch.fromJson(json) as T;
      default:
        throw UnimplementedError();
    }
    obj.id = objId;
    return obj;
  }

  Map<dynamic, dynamic> toJson();

  void generateIdIfNull() {
    id ??= ObjectId().toString();
  }

  @override
  String toString() => toJson().toString();

  @override
  operator ==(other) => other is Model && other.id == id;
  
  @override
  int get hashCode => Object.hash(id, id);  
  
}