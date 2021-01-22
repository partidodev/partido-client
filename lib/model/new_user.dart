import 'package:json_annotation/json_annotation.dart';
import 'package:partido_client/model/user.dart';

part 'new_user.g.dart';

@JsonSerializable()
class NewUser extends User {
  String? password;
  String? newPassword;

  NewUser({this.password, this.newPassword});

  factory NewUser.fromJson(Map<String, dynamic> json) => _$NewUserFromJson(json);
  Map<String, dynamic> toJson() => _$NewUserToJson(this);
}
