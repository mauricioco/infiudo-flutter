import 'package:infiudo/models/model.dart';

abstract class Repository<T extends Model> {
  
  String collection;

  Repository({required this.collection});

}