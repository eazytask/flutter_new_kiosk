// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      image: json['image'] as String?,
      name: json['name'] as String?,
      mName: json['mname'] as String?,
      lName: json['lname'] as String?,
      email: json['email'] as String?,
      pin: json['pin'] as int?,
      currentCompanyCode: json['current_company_code'] as String?,
      currentCompany: json['current_company'] as int?,
      currentRole: json['current_role'] as int?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'name': instance.name,
      'mname': instance.mName,
      'lname': instance.lName,
      'email': instance.email,
      'pin': instance.pin,
      'current_company_code': instance.currentCompanyCode,
      'current_company': instance.currentCompany,
      'current_role': instance.currentRole,
      'token': instance.token,
    };
