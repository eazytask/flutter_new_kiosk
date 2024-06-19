import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.details.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShiftDetails extends Equatable {
  final int? id;
  final DateTime? roasterDate;
  final DateTime? shiftStart;
  final DateTime? shiftEnd;
  final DateTime? singIn;
  final DateTime? singOut;
  final int? jobTypeId;

  const ShiftDetails({
    required this.id,
    required this.roasterDate,
    required this.shiftStart,
    required this.shiftEnd,
    required this.singIn,
    required this.singOut,
    required this.jobTypeId,
  });

  factory ShiftDetails.fromJson(Map<String, dynamic> json) =>
      _$ShiftDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftDetailsToJson(this);

  @override
  List<Object?> get props => [
    id,
    roasterDate,
    shiftStart,
    shiftEnd,
    singIn,
    singOut,
    jobTypeId,
  ];
}