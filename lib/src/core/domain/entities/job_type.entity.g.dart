// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_type.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobType _$JobTypeFromJson(Map<String, dynamic> json) => JobType(
      id: json['id'] as int?,
      name: json['name'] as String?,
      userId: json['user_id'] as int?,
      companyCode: json['company_code'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$JobTypeToJson(JobType instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'user_id': instance.userId,
      'company_code': instance.companyCode,
      'remarks': instance.remarks,
      'created_at': instance.createdAt?.toIso8601String(),
    };
