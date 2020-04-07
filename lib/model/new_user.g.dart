// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewUser _$NewUserFromJson(Map<String, dynamic> json) {
  return NewUser(
    password: json['password'] as String,
  )
    ..id = json['id'] as int
    ..username = json['username'] as String
    ..email = json['email'] as String;
}

Map<String, dynamic> _$NewUserToJson(NewUser instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
    };
