// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      id: json['id'] as int?,
      fName: json['fname'] as String?,
      mName: json['mname'] as String?,
      lName: json['lname'] as String?,
      role: json['role'] as int?,
      address: json['address'] as String?,
      suburb: json['suburb'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      email: json['email'] as String?,
      status: json['status'] as int?,
      contactNumber: json['contact_number'] as String?,
      licenseNo: json['license_no'] as String?,
      licenseExpireDate: json['license_expire_date'] == null
          ? null
          : DateTime.parse(json['license_expire_date'] as String),
      firstAidLicense: json['first_aid_license'] as String?,
      firstAidExpireDate: json['first_aid_expire_date'] == null
          ? null
          : DateTime.parse(json['first_aid_expire_date'] as String),
      image: json['image'] as String?,
      shiftDetails: (json['shiftDetails'] as List<dynamic>?)
          ?.map((e) => ShiftDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'id': instance.id,
      'fname': instance.fName,
      'mname': instance.mName,
      'lname': instance.lName,
      'role': instance.role,
      'address': instance.address,
      'suburb': instance.suburb,
      'state': instance.state,
      'postal_code': instance.postalCode,
      'email': instance.email,
      'status': instance.status,
      'contact_number': instance.contactNumber,
      'license_no': instance.licenseNo,
      'license_expire_date': instance.licenseExpireDate?.toIso8601String(),
      'first_aid_license': instance.firstAidLicense,
      'first_aid_expire_date': instance.firstAidExpireDate?.toIso8601String(),
      'image': instance.image,
    };
