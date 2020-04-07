// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) {
  return Group(
    id: json['id'] as int,
    name: json['name'] as String,
    status: json['status'] as String,
    currency: json['currency'] as String,
    joinModeActive: json['joinModeActive'] as bool,
    joinKey: json['joinKey'] as String,
    founder: json['founder'] as int,
    users: (json['users'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'currency': instance.currency,
      'joinModeActive': instance.joinModeActive,
      'joinKey': instance.joinKey,
      'founder': instance.founder,
      'users': instance.users,
    };
