import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User extends Equatable {
  final int id;
  final String? image;
  final String? name;
  @JsonKey(name: "mname")
  final String? mName;
  @JsonKey(name: "lname")
  final String? lName;
  final String? email;
  final int? pin;
  final String? currentCompanyCode;
  final int? currentCompany;
  final int? currentRole;
  final String? token;

  const User({
    required this.id,
    required this.image,
    required this.name,
    required this.mName,
    required this.lName,
    required this.email,
    required this.pin,
    required this.currentCompanyCode,
    required this.currentCompany,
    required this.currentRole,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        id,
        image,
        name,
        mName,
        lName,
        email,
        pin,
        currentCompanyCode,
        currentCompany,
        currentRole,
        token,
      ];

  Map<String, dynamic> toMap() => {
    "id": id,
    "image": image,
    "name": name,
    "mname": mName,
    "lname": lName,
    "email": email,
    "pin": pin,
    "current_company_code": currentCompanyCode,
    "current_company": currentCompany,
    "current_role": currentRole,
    "token": token,
  };
}
