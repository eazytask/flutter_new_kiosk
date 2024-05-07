// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      latitude: json['lat'] as String?,
      longitude: json['lon'] as String?,
      projectName: json['pName'] as String?,
      contactName: json['cName'] as String?,
      status: json['Status'] as String?,
      contactNumber: json['cNumber'] as String?,
      clientName: json['clientName'] as int?,
      projectAddress: json['project_address'] as String?,
      suburb: json['suburb'] as String?,
      projectState: json['project_state'] as String?,
      postalCode: json['postal_code'] as String?,
      companyCode: json['company_code'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'lat': instance.latitude,
      'lon': instance.longitude,
      'pName': instance.projectName,
      'cName': instance.contactName,
      'Status': instance.status,
      'cNumber': instance.contactNumber,
      'clientName': instance.clientName,
      'project_address': instance.projectAddress,
      'suburb': instance.suburb,
      'project_state': instance.projectState,
      'postal_code': instance.postalCode,
      'company_code': instance.companyCode,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
