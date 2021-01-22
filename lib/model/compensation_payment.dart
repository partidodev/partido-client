import 'package:json_annotation/json_annotation.dart';

part 'compensation_payment.g.dart';

@JsonSerializable()
class CompensationPayment {

  int fromUser;
  int toUser;
  double amount;

  CompensationPayment({required this.fromUser, required this.toUser, required this.amount});

  factory CompensationPayment.fromJson(Map<String, dynamic> json) => _$CompensationPaymentFromJson(json);
  Map<String, dynamic> toJson() => _$CompensationPaymentToJson(this);
}
