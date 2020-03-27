import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Balance {
  int user;
  double balance;

  Balance({this.user, this.balance});

  factory Balance.fromJson(Map<String, dynamic> json) => _BalanceFromJson(json);
}
