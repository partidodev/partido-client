import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:partido_client/model/bill.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';
import 'bill_form_page.dart';

class BillDetailsPage extends StatelessWidget {
  final Bill bill;

  // Constructor needs an bill object to show it's details page
  BillDetailsPage({Key key, @required this.bill}) : super(key: key);

  NumberFormat currencyFormatter;
  NumberFormat partFormatter;
  DateFormat dateFormatter;

  @override
  Widget build(BuildContext context) {
    dateFormatter =
        new DateFormat(FlutterI18n.translate(context, "global.date_format"));
    currencyFormatter = new NumberFormat(
        FlutterI18n.translate(context, "global.currency_format"),
        FlutterI18n.translate(context, "global.locale"));
    partFormatter = new NumberFormat(
        FlutterI18n.translate(context, "global.part_format"),
        FlutterI18n.translate(context, "global.locale"));
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LinearIcons.arrow_left),
            onPressed: () {
              navService.goBack();
            },
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          title: I18nText('bill_details.title'),
          actions: Provider.of<AppState>(context, listen: false)
                      .getCurrentUser()
                      .id ==
                  bill.creator
              ? <Widget>[
                  IconButton(
                      icon: Icon(LinearIcons.pencil_line),
                      onPressed: () {
                        navService.push(
                          MaterialPageRoute(
                            builder: (context) => BillFormPage(bill: bill),
                          ),
                        );
                      }),
                ]
              : null,
        ),
        body: ListView(
          padding: EdgeInsets.all(4),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child:
                      Consumer<AppState>(builder: (context, appState, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            '${bill.description}',
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(
                              '${FlutterI18n.translate(context, "bill_details.created_by")} ${Provider.of<AppState>(context, listen: false).getUserFromGroupById(bill.creator).username}'),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                  appState.getAvailableBillCategories()[bill.category],
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
                      ListTile(
                        title: I18nText('bill.categories.${bill.category}'),
                        leading: Icon(LinearIcons.tag),
                      ),
                      ListTile(
                        title: Text(
                            '${currencyFormatter.format(bill.totalAmount)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}'),
                        leading: Icon(LinearIcons.bag_dollar),
                      ),
                      ListTile(
                        title: Text(
                            '${dateFormatter.format(new DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(bill.billingDate))}'),
                        leading: Icon(LinearIcons.calendar_31),
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
                          FlutterI18n.translate(context, "bill_details.splits"),
                          style: TextStyle(fontSize: 18),
                        ),
                        leading:
                            Icon(LinearIcons.arrows_split, color: Colors.green),
                      ),
                      Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bill.splits.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(LinearIcons.user)
                              ],
                            ),
                            title: Text(
                                '${Provider.of<AppState>(context, listen: false).getUserFromGroupById(bill.splits[index].debtor).username}'),
                            subtitle: Text(
                                '${FlutterI18n.translate(context, "bill_details.parts")} ${partFormatter.format(bill.splits[index].partsOfBill)}/${partFormatter.format(bill.parts)} · ${FlutterI18n.translate(context, "bill_details.paid")} ${currencyFormatter.format(bill.splits[index].paid)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}'),
                            trailing: Text(
                              '${currencyFormatter.format(bill.totalAmount / bill.parts * bill.splits[index].partsOfBill)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}',
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
        ));
  }
}
