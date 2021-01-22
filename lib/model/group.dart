import 'package:json_annotation/json_annotation.dart';
import 'package:partido_client/model/user.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  int? id;
  String? name;
  String? status;
  String? currency;
  bool? joinModeActive;
  String? joinKey;
  int? founder;
  List<User> users;

  Group({
    this.id,
    this.name,
    this.status,
    this.currency,
    this.joinModeActive,
    this.joinKey,
    this.founder,
    required this.users
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}
