import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Shift extends Equatable {
  final int? id;
  final int? employeeId;
  final Project? project;
  final DateTime? roasterDate;
  final DateTime? shiftStart;
  final DateTime? shiftEnd;
  final DateTime? singIn;
  final DateTime? singOut;
  final double? duration;
  @JsonKey(name: 'ratePerHour')
  final double? ratePerHour;
  final double? amount;
  final JobType? jobType;
  final String? roasterType;
  final int? paymentStatus;
  final int? isApproved;
  final int? isApplied;
  final String? remarks;

  const Shift({
    required this.id,
    required this.employeeId,
    required this.project,
    required this.roasterDate,
    required this.shiftStart,
    required this.shiftEnd,
    required this.singIn,
    required this.singOut,
    required this.duration,
    required this.ratePerHour,
    required this.amount,
    required this.jobType,
    required this.roasterType,
    required this.paymentStatus,
    required this.isApproved,
    required this.isApplied,
    required this.remarks,
  });

  factory Shift.fromJson(Map<String, dynamic> json) =>
      _$ShiftFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftToJson(this);

  @override
  List<Object?> get props => [
    id,
    employeeId,
    project,
    roasterDate,
    shiftStart,
    shiftEnd,
    singIn,
    singOut,
    duration,
    ratePerHour,
    amount,
    jobType,
    roasterType,
    paymentStatus,
    isApproved,
    isApplied,
    remarks,
  ];
}