import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:partido_client/model/bill.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class BillDetailsPage extends StatelessWidget {
  final Bill bill;

  // Constructor needs an bill object to show it's details page
  BillDetailsPage({Key key, @required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Bill Details'),
          actions: Provider.of<AppState>(context, listen: false)
                      .getCurrentUser()
                      .id ==
                  bill.creator
              ? <Widget>[
                  IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                ]
              : null,
        ),
        body: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          '${bill.description}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        subtitle: Text(
                            'Created by ${Provider.of<AppState>(context, listen: false).getUserFromGroupById(bill.creator).username}'),
                        leading: Icon(Icons.description,
                            size: 40, color: Colors.green),
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
                            '${bill.totalAmount.toStringAsFixed(2)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}'),
                        leading: Icon(Icons.attach_money),
                      ),
                      ListTile(
                        title: Text(
                            '${new DateFormat("yyyy-MM-dd").format(new DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(bill.billingDate))}'),
                        leading: Icon(Icons.date_range),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text('Splits',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        leading: Icon(Icons.call_split, color: Colors.green),
                      ),
                      Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        //padding: EdgeInsets.only(bottom: 70),
                        itemCount: bill.splits.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                                '${Provider.of<AppState>(context, listen: false).getUserFromGroupById(bill.splits[index].debtor).username}'),
                            subtitle: Text(
                                'Paid ${(bill.splits[index].paid).toStringAsFixed(2)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}'),
                            trailing: Text(
                                '${(bill.totalAmount / bill.parts * bill.splits[index].partsOfBill).toStringAsFixed(2)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}'),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        )
    );
  }
}
