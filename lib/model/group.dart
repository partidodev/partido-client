import 'package:json_annotation/json_annotation.dart';
import 'package:partido_flutter/model/user.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  int id;
  String name;
  String status;
  String currency;
  int founder;
  List<User> users = null;

  Group(
      {this.id,
      this.name,
      this.status,
      this.currency,
      this.founder,
      this.users});

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}
