// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(Map json) => Result(
      watchId: json['watchId'] as String,
      favorite: json['favorite'] as bool,
      currentData: ResultData.fromJson(json['currentData']),
      snapshots: (json['snapshots'] as List<dynamic>)
          .map((e) => ResultData.fromJson(e as Map))
          .toList()
    );
    
Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'watchId': instance.watchId,
      'favorite': instance.favorite,
      'currentData': instance.currentData.toJson(),
      'snapshots': instance.snapshots.map((e) => e.toJson()).toList(),
    };

ResultData _$ResultDataFromJson(Map json) => ResultData(
      timestamp: json['timestamp'] as DateTime,
      data: json['data'] as Map,
    );

Map<String, dynamic> _$ResultDataToJson(ResultData instance) => <String, dynamic>{
      'timestamp': instance.timestamp,
      'data': instance.data,
    };
