import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Employee extends Equatable {
  final int? id;
  @JsonKey(name: "fname")
  final String? fName;
  @JsonKey(name: "mname")
  final String? mName;
  @JsonKey(name: "lname")
  final String? lName;
  final int? role;
  final String? address;
  final String? suburb;
  final String? state;
  final String? postalCode;
  final String? email;
  final int? status;
  final String? contactNumber;
  final String? licenseNo;
  final DateTime? licenseExpireDate;
  final String? firstAidLicense;
  final DateTime? firstAidExpireDate;
  final String? image;

  const Employee({
    required this.id,
    required this.fName,
    required this.mName,
    required this.lName,
    required this.role,
    required this.address,
    required this.suburb,
    required this.state,
    required this.postalCode,
    required this.email,
    required this.status,
    required this.contactNumber,
    required this.licenseNo,
    required this.licenseExpireDate,
    required this.firstAidLicense,
    required this.firstAidExpireDate,
    required this.image,
  });

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  @override
  List<Object?> get props => [
        id,
        fName,
        mName,
        lName,
        role,
        address,
        suburb,
        state,
        postalCode,
        email,
        status,
        contactNumber,
        licenseNo,
        licenseExpireDate,
        firstAidLicense,
        firstAidExpireDate,
        image,
      ];
}
