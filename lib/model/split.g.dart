// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Split _$SplitFromJson(Map<String, dynamic> json) {
  return Split(
    id: json['id'] as int,
    debtor: json['debtor'] as int,
    paid: (json['paid'] as num)?.toDouble(),
    partsOfBill: (json['partsOfBill'] as num)?.toDouble(),
    main: json['main'] as bool,
  );
}

Map<String, dynamic> _$SplitToJson(Split instance) => <String, dynamic>{
      'id': instance.id,
      'debtor': instance.debtor,
      'paid': instance.paid,
      'partsOfBill': instance.partsOfBill,
      'main': instance.main,
    };
