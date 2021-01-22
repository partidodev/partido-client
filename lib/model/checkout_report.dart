import 'package:json_annotation/json_annotation.dart';

import 'compensation_payment.dart';

part 'checkout_report.g.dart';

@JsonSerializable()
class CheckoutReport {

  String timestamp;
  List<CompensationPayment> compensationPayments;

  CheckoutReport({required this.timestamp, required this.compensationPayments});

  factory CheckoutReport.fromJson(Map<String, dynamic> json) => _$CheckoutReportFromJson(json);
  Map<String, dynamic> toJson() => _$CheckoutReportToJson(this);
}
