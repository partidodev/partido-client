import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  int id;
  String username;
  String email;
  String birthday;

  User({this.id, this.username, this.email, this.birthday});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
