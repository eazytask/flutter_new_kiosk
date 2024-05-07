// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shift _$ShiftFromJson(Map<String, dynamic> json) => Shift(
      id: json['id'] as int?,
      employeeId: json['employee_id'] as int?,
      project: json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
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
      duration: (json['duration'] as num?)?.toDouble(),
      ratePerHour: (json['ratePerHour'] as num?)?.toDouble(),
      amount: (json['amount'] as num?)?.toDouble(),
      jobType: json['job_type'] == null
          ? null
          : JobType.fromJson(json['job_type'] as Map<String, dynamic>),
      roasterType: json['roaster_type'] as String?,
      paymentStatus: json['payment_status'] as int?,
      isApproved: json['is_approved'] as int?,
      isApplied: json['is_applied'] as int?,
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$ShiftToJson(Shift instance) => <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'project': instance.project,
      'roaster_date': instance.roasterDate?.toIso8601String(),
      'shift_start': instance.shiftStart?.toIso8601String(),
      'shift_end': instance.shiftEnd?.toIso8601String(),
      'sing_in': instance.singIn?.toIso8601String(),
      'sing_out': instance.singOut?.toIso8601String(),
      'duration': instance.duration,
      'ratePerHour': instance.ratePerHour,
      'amount': instance.amount,
      'job_type': instance.jobType,
      'roaster_type': instance.roasterType,
      'payment_status': instance.paymentStatus,
      'is_approved': instance.isApproved,
      'is_applied': instance.isApplied,
      'remarks': instance.remarks,
    };
