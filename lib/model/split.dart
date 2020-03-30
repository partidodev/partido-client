import 'package:json_annotation/json_annotation.dart';

part 'split.g.dart';

@JsonSerializable()
class Split {

  int id;
  int debtor;
  double paid;
  double partsOfBill;
  bool main;

  Split({this.id, this.debtor, this.paid, this.partsOfBill, this.main});

  factory Split.fromJson(Map<String, dynamic> json) => _$SplitFromJson(json);
  Map<String, dynamic> toJson() => _$SplitToJson(this);
}
