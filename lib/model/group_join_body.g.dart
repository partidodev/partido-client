// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_join_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupJoinBody _$GroupJoinBodyFromJson(Map<String, dynamic> json) {
  return GroupJoinBody(
    userId: json['userId'] as int,
    joinKey: json['joinKey'] as String,
  );
}

Map<String, dynamic> _$GroupJoinBodyToJson(GroupJoinBody instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'joinKey': instance.joinKey,
    };
