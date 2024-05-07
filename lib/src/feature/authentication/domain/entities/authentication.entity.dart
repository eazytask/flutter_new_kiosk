import 'package:kiosk/src/core/domain/entities/user.entity.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Authentication extends Equatable {
  final User user;

  const Authentication({
    required this.user,
  });

  factory Authentication.fromJson(Map<String, dynamic> json) => _$AuthenticationFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticationToJson(this);

  @override
  List<Object?> get props => [user];
}