import 'package:json_annotation/json_annotation.dart';
import 'package:partido_client/model/split.dart';

part 'bill.g.dart';

@JsonSerializable()
class Bill {
  int id;
  String description;
  double totalAmount;
  String billingDate;
  String creationDate;
  double parts;
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
  Map<String, dynamic> toJson() => _$BillToJson(this);
}
