import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_type.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class JobType extends Equatable {
  final int? id;
  final String? name;
  final int? userId;
  final String? companyCode;
  final String? remarks;
  final DateTime? createdAt;

  const JobType({
    required this.id,
    required this.name,
    required this.userId,
    required this.companyCode,
    required this.remarks,
    required this.createdAt,
  });

  factory JobType.fromJson(Map<String, dynamic> json) =>
      _$JobTypeFromJson(json);

  Map<String, dynamic> toJson() => _$JobTypeToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    userId,
    companyCode,
    remarks,
    createdAt,
  ];
}
