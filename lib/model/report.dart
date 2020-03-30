import 'package:json_annotation/json_annotation.dart';
import 'package:partido_flutter/model/balance.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {

  String timestamp;
  List<Balance> balances;

  Report({this.timestamp, this.balances});

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
