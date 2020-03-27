import 'package:json_annotation/json_annotation.dart';
import 'package:partido_flutter/model/user.dart';

@JsonSerializable()
class NewUser extends User {

  String password;

  NewUser({this.password});

  factory NewUser.fromJson(Map<String, dynamic> json) => _$NewUserFromJson(json);
}
