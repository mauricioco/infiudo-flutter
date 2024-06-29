import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/mapper.dart';
import 'package:infiudo/models/model.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/ui_mapper.dart';
import 'package:infiudo/models/watch.dart';

class CacheHelper {

  static final CacheHelper _presetHelper = CacheHelper._internal();

  CacheHelper._internal();

  factory CacheHelper() {
    return _presetHelper;
  }

  final Map<String, Service> _serviceCache = {};
  final Map<String, Watch> _watchCache = {};
  final Map<String, Mapper> _mapperCache = {};
  final Map<String, UIMapper> _uiMapperCache = {};

  Future<void> refreshCache() async {
    for (var s in (await DbHive().getAll<Service>())) { _serviceCache[s.id!] = s; }
    for (var w in (await DbHive().getAll<Watch>())) { _watchCache[w.id!] = w; }
    for (var m in (await DbHive().getAll<Mapper>())) { _mapperCache[m.id!] = m; }
    for (var um in (await DbHive().getAll<UIMapper>())) { _uiMapperCache[um.id!] = um; }
  }

  Future<T?> getItem<T extends Model>(String id) async {
    T? item = await DbHive().get<T>(id);
    switch(T) {
      case Service:
        _serviceCache[id] = item as Service;
        return item;
      case Mapper:
        _mapperCache[id] = item as Mapper;
        return item;
      case UIMapper:
        _uiMapperCache[id] = item as UIMapper;
        return item;
      case Watch:
        _watchCache[id] = item as Watch;
        return item;
      default:
        throw UnimplementedError();
    }
  }

  T? getCached<T extends Model>(String id) {
    switch(T) {
      case Service:
        return _serviceCache[id] as T?;
      case Mapper:
        return _mapperCache[id] as T?;
      case UIMapper:
        return _uiMapperCache[id] as T?;
      case Watch:
        return _watchCache[id] as T?;
      default:
        throw UnimplementedError();
    }
  }

  T updateCached<T extends Model>(T item) {
    switch(T) {
      case Service:
        _serviceCache[item.id!] = item as Service;
        return item;
      case Mapper:
        _mapperCache[item.id!] = item as Mapper;
        return item;
      case UIMapper:
        _uiMapperCache[item.id!] = item as UIMapper;
        return item;
      case Watch:
        _watchCache[item.id!] = item as Watch;
        return item;
      default:
        throw UnimplementedError();
    }
  }

  T deleteCached<T extends Model>(T item) {
    switch(T) {
      case Service:
        _serviceCache.remove(item.id!);
        return item;
      case Mapper:
        _mapperCache.remove(item.id!);
        return item;
      case UIMapper:
        _uiMapperCache.remove(item.id!);
        return item;
      case Watch:
        _watchCache.remove(item.id!);
        return item;
      default:
        throw UnimplementedError();
    }
  }

  List<Service> getCachedServices() {
    return _serviceCache.values.toList();
  }

  // TODO check if can be non-growable
  List<Watch> getCachedWatches() {
    return _watchCache.values.toList();
  }

}