import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:partido_client/model/entry.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';
import 'entry_form_page.dart';

class EntryDetailsPage extends StatelessWidget {
  final Entry entry;

  // Constructor needs an entry object to show it's details page
  EntryDetailsPage({Key key, @required this.entry}) : super(key: key);

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
          title: I18nText('entry_details.title'),
          actions: Provider.of<AppState>(context, listen: false)
                      .getCurrentUser()
                      .id ==
                  entry.creator
              ? <Widget>[
                  IconButton(
                      icon: Icon(LinearIcons.pencil_line),
                      onPressed: () {
                        navService.push(
                          MaterialPageRoute(
                            builder: (context) => EntryFormPage(entry: entry),
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
                            '${entry.description}',
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(
                              '${FlutterI18n.translate(context, "entry_details.created_by")} ${Provider.of<AppState>(context, listen: false).getUserFromGroupById(entry.creator).username}'),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                  appState.getAvailableEntryCategories()[entry.category],
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
                        title: I18nText('entry.categories.${entry.category}'),
                        leading: Icon(LinearIcons.tag),
                      ),
                      ListTile(
                        title: Text(
                            '${currencyFormatter.format(entry.totalAmount)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}'),
                        leading: Icon(LinearIcons.bag_dollar),
                      ),
                      ListTile(
                        title: Text(
                            '${dateFormatter.format(new DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(entry.billingDate))}'),
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
                          FlutterI18n.translate(context, "entry_details.splits"),
                          style: TextStyle(fontSize: 18),
                        ),
                        leading:
                            Icon(LinearIcons.arrows_split, color: Colors.green),
                      ),
                      Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.splits.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(LinearIcons.user)
                              ],
                            ),
                            title: Text(
                                '${Provider.of<AppState>(context, listen: false).getUserFromGroupById(entry.splits[index].debtor).username}'),
                            subtitle: Text(
                                '${FlutterI18n.translate(context, "entry_details.parts")} ${partFormatter.format(entry.splits[index].partsOfBill)}/${partFormatter.format(entry.parts)} · ${FlutterI18n.translate(context, "entry_details.paid")} ${currencyFormatter.format(entry.splits[index].paid)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}'),
                            trailing: Text(
                              '${currencyFormatter.format(entry.totalAmount / entry.parts * entry.splits[index].partsOfBill)} ${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}',
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
