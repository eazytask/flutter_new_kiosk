import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Project extends Equatable {
  final int? id;
  final int? userId;
  @JsonKey(name: "lat")
  final String? latitude;
  @JsonKey(name: "lon")
  final String? longitude;
  @JsonKey(name: "pName")
  final String? projectName;
  @JsonKey(name: "cName")
  final String? contactName;
  @JsonKey(name: "Status")
  final String? status;
  @JsonKey(name: "cNumber")
  final String? contactNumber;
  @JsonKey(name: "clientName")
  final int? clientName;
  final String? projectAddress;
  final String? suburb;
  final String? projectState;
  final String? postalCode;
  final String? companyCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.projectName,
    required this.contactName,
    required this.status,
    required this.contactNumber,
    required this.clientName,
    required this.projectAddress,
    required this.suburb,
    required this.projectState,
    required this.postalCode,
    required this.companyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        latitude,
        longitude,
        projectName,
        contactName,
        status,
        contactNumber,
        clientName,
        projectAddress,
        suburb,
        projectState,
        postalCode,
        companyCode,
        createdAt,
        updatedAt,
      ];
}
