// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) {
  return Bill(
    id: json['id'] as int,
    description: json['description'] as String,
    totalAmount: (json['totalAmount'] as num)?.toDouble(),
    billingDate: json['billingDate'] as String,
    creationDate: json['creationDate'] as String,
    parts: (json['parts'] as num)?.toDouble(),
    creator: json['creator'] as int,
    splits: (json['splits'] as List)
        ?.map(
            (e) => e == null ? null : Split.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'totalAmount': instance.totalAmount,
      'billingDate': instance.billingDate,
      'creationDate': instance.creationDate,
      'parts': instance.parts,
      'creator': instance.creator,
      'splits': instance.splits,
    };
