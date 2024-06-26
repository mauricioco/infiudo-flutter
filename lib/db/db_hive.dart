import 'package:hive/hive.dart';
import 'package:infiudo/models/mapper.dart';

import 'package:infiudo/models/model.dart';
import 'package:infiudo/models/result.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/models/watch.dart';

class DbHive {

  // TODO: exceptions and null check
  // TODO: review box closing, as it's returning errors of "already closed"

  static final DbHive _dbHive = DbHive._internal();
  
  static String getBoxName<T extends Model>() {
    switch(T) {
      case Service:
        return "service";
      case Mapper:
        return "mapper";
      case UIMapper:
        return "ui_mapper";
      case Result:
        return "result_";
      case Watch:
        return "watch";
      default:
        throw UnimplementedError();
    }
  }

  factory DbHive() {
    return _dbHive;
  }

  DbHive._internal();   // pra que isso?? Constructor!

  dynamic _openBox(String boxName, {String? boxModifier}) async {
    if (boxModifier != null) {
      boxName += '_$boxModifier';
    }
    return await Hive.openBox(boxName);
  }

  Future<Map<String, dynamic>?> getGeneric<T extends Model>(String id, {String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    var boxItem = await box.get(id);
    boxItem['id'] = id;
    //await box.close();
    return boxItem;
  }

  Future<List<Map<String, dynamic>?>> getAllGeneric<T extends Model>({String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    List<Map<String, dynamic>> items = [];
    box.toMap().forEach((key, value) {
      items.add({...value, 'id': key});
    });
    //await box.close();
    return items;
  }

  Future<T?> get<T extends Model>(String id, {String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    var boxItem = await box.get(id);
    T? item;
    if (boxItem != null) {
      item = Model.fromJson(id, boxItem);
    }
    //await box.close();
    return item;
  }

  Future<List<T>> getWhere<T extends Model>(bool Function(dynamic K, T element) where, {String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    List<T> items = [];
    var boxMap = box.toMap();
    boxMap.forEach((key, value) {
      final T item = Model.fromJson<T>(key, value);
      if(where(key, item)) {
        items.add(item);
      }
    });
    //await box.close();
    return items;
  }

  Future<List<T>> getAll<T extends Model>({String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    List<T> items = [];
    box.toMap().forEach((key, value) {
      final T item = Model.fromJson<T>(key, value);
      items.add(item);
    });
    //await box.close();
    return items;
  }

  Future<T> save<T extends Model>(T item, {String? boxModifier}) async {
    item.generateIdIfNull();
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    await box.put(item.id, item.toJson());
    await box.close();
    return item;
  }

  Future<List<T>> saveAll<T extends Model>(List<T> items, {String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    final Map<dynamic, dynamic> itemsToSave = {};
    for (T item in items) {
      item.generateIdIfNull();
      itemsToSave[item.id] = item.toJson();
    }
    await box.putAll(itemsToSave);
    await box.close();
    return items;
  }

  Future<T> deleteLogical<T extends Model>(T item) async {
    item.deleted = true;
    await save(item);
    return item;
  }

  Future<T?> delete<T extends Model>(T item, {String? boxModifier}) async {
    if (item.id == null) {
      return null;
    }
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    await box.delete(item.id);
    await box.close();
    return item;
  }

  Future<T?> deleteWithId<T extends Model>(String itemId, {String? boxModifier}) async {
    // TODO should check if it exists before
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    await box.delete(itemId);
    await box.close();
    return null;
  }

  Future<T?> deleteAll<T extends Model>({String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    await box.clear();
    await box.close();
    return null;
  }

}