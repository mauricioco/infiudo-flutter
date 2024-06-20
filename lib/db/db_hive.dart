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

  Future<T?> get<T extends Model>(String id, {String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    var boxItem = await box.get(id);
    T? item;
    if (boxItem != null) {
      item = Model.fromJson(id, box.get(id));
      item.id = id;
    }
    //await box.close();
    return item;
  }

  Future<List<T>> getAll<T extends Model>({String? boxModifier}) async {
    String boxName = getBoxName<T>();
    var box = await _openBox(boxName, boxModifier: boxModifier);
    List<T> items = [];
    box.toMap().forEach((key, value) {
      final T item = Model.fromJson<T>(key, value);
      item.id = key;
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

  Future<T?> delete<T extends Model>(String itemId, {String? boxModifier}) async {
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