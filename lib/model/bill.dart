import 'package:json_annotation/json_annotation.dart';
import 'package:partido_flutter/model/split.dart';

@JsonSerializable()
class Bill {
  int id;
  String description;
  double totalAmount;
  String billingDate;
  String creationDate;
  int parts;
  int creator;
  List<Split> splits = null;

  Bill(
      {this.id,
      this.description,
      this.totalAmount,
      this.billingDate,
      this.creationDate,
      this.parts,
      this.creator,
      this.splits});

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
}
