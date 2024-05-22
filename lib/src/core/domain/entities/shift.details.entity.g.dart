// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.details.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftDetails _$ShiftDetailsFromJson(Map<String, dynamic> json) => ShiftDetails(
      id: json['id'] as int?,

      roasterDate: json['roaster_date'] == null
          ? null
          : DateTime.parse(json['roaster_date'] as String),
      shiftStart: json['shift_start'] == null
          ? null
          : DateTime.parse(json['shift_start'] as String),
      shiftEnd: json['shift_end'] == null
          ? null
          : DateTime.parse(json['shift_end'] as String),
      singIn: json['sing_in'] == null
          ? null
          : DateTime.parse(json['sing_in'] as String),
      singOut: json['sing_out'] == null
          ? null
          : DateTime.parse(json['sing_out'] as String),
      jobTypeId: json['job_type_id'],

    );

Map<String, dynamic> _$ShiftDetailsToJson(ShiftDetails instance) => <String, dynamic>{
      'id': instance.id,
      'roaster_date': instance.roasterDate?.toIso8601String(),
      'shift_start': instance.shiftStart?.toIso8601String(),
      'shift_end': instance.shiftEnd?.toIso8601String(),
      'sing_in': instance.singIn?.toIso8601String(),

      'job_type_id': instance.jobTypeId,
    };
