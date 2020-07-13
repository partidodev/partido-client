import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:partido_client/model/checkout_report.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';

class CheckoutResultPage extends StatelessWidget {

  final CheckoutReport checkoutReport;

  // Constructor needs an entry object to show it's details page
  CheckoutResultPage({Key key, @required this.checkoutReport}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    NumberFormat currencyFormatter;
    DateFormat dateFormatter;

    dateFormatter = new DateFormat(FlutterI18n.translate(context, "global.date_format"));
    currencyFormatter = new NumberFormat(
        FlutterI18n.translate(context, "global.currency_format"),
        FlutterI18n.translate(context, "global.locale"),
    );

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LinearIcons.arrow_left),
            onPressed: () {
              navService.goBack();
            },
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          title: I18nText('checkout_result.title'),
          actions: <Widget>[
            IconButton(
                icon: Icon(LinearIcons.check),
                onPressed: () {
                  navService.goBack();
                },
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(4),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Consumer<AppState>(builder: (context, appState, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            '${FlutterI18n.translate(context, "checkout_result.subtitle")}',
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Text('${dateFormatter.format(new DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(checkoutReport.timestamp))}'),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                  LinearIcons.dolly,
                                  size: 30,
                                  color: Colors.green
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FlutterI18n.translate(context, "checkout_result.success_notice"),
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16),
                            Text(
                              FlutterI18n.translate(context, "checkout_result.additional_info"),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          FlutterI18n.translate(context, "checkout_result.compensation_payments.title"),
                          style: TextStyle(fontSize: 18),
                        ),
                        leading: Icon(LinearIcons.balance, color: Colors.green),
                      ),
                      Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: checkoutReport.compensationPayments.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                '${Provider.of<AppState>(context, listen: false).getUserFromGroupById(checkoutReport.compensationPayments[index].fromUser).username}'
                                    + ' ➞ '
                                    + '${Provider.of<AppState>(context, listen: false).getUserFromGroupById(checkoutReport.compensationPayments[index].toUser).username}'
                            ),
                            trailing: Text(
                              '${currencyFormatter.format(checkoutReport.compensationPayments[index].amount)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
    );
  }
}
