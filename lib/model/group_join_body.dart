import 'package:json_annotation/json_annotation.dart';

part 'group_join_body.g.dart';

@JsonSerializable()
class GroupJoinBody {
  int? userId;
  String? joinKey;

  GroupJoinBody({this.userId, this.joinKey});

  factory GroupJoinBody.fromJson(Map<String, dynamic> json) => _$GroupJoinBodyFromJson(json);
  Map<String, dynamic> toJson() => _$GroupJoinBodyToJson(this);
}
