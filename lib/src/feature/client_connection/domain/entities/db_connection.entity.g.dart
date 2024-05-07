// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_connection.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientConnection _$ClientConnectionFromJson(Map<String, dynamic> json) =>
    ClientConnection(
      id: json['id'] as int,
      key: json['key'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ClientConnectionToJson(ClientConnection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'name': instance.name,
    };
