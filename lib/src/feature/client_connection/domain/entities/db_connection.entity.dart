// ignore: import_of_legacy_library_into_null_safe
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'db_connection.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class ClientConnection extends Equatable {
  final int id;
  final String? key;
  final String? name;

  ClientConnection({
    required this.id,
    required this.key,
    required this.name,
  });

  factory ClientConnection.fromJson(Map<String, dynamic> json) =>
      _$ClientConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$ClientConnectionToJson(this);

  @override
  List<Object> get props => [
        id,
        key ?? "",
        name ?? "",
      ];

  @override
  String toString() {
    return 'DbConnection{id: $id, key: $key, name: $name}';
  }
}
