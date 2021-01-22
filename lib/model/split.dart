import 'package:json_annotation/json_annotation.dart';

part 'split.g.dart';

@JsonSerializable()
class Split {

  int? id;
  int? debtor;
  double? paid;
  double? partsOfBill;

  Split({this.id, this.debtor, this.paid, this.partsOfBill});

  factory Split.fromJson(Map<String, dynamic> json) => _$SplitFromJson(json);
  Map<String, dynamic> toJson() => _$SplitToJson(this);
}
