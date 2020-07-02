import 'package:json_annotation/json_annotation.dart';
import 'package:partido_client/model/split.dart';

part 'entry.g.dart';

@JsonSerializable()
class Entry {
  int id;
  String description;
  String category;
  double totalAmount;
  String billingDate;
  String creationDate;
  double parts;
  int creator;
  List<Split> splits = null;

  Entry({
    this.id,
    this.description,
    this.category,
    this.totalAmount,
    this.billingDate,
    this.creationDate,
    this.parts,
    this.creator,
    this.splits
  });

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
  Map<String, dynamic> toJson() => _$EntryToJson(this);
}
