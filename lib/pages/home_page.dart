import 'package:partido_client/pages/bill_details_page.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Api api = ApiService.getApi();

  void _logout() async {
    try {
      HttpResponse<String> response = await api.logout();
    } catch (e) {
      // Logout causes always a 401 or 302 (redirect to /login).
      // That's why we just catch the error and open login page.
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  Future _openGroupsDialog() async {
    await showDialog(
        context: context,
        child: Consumer<AppState>(builder: (context, appState, child) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
            title: Text("My Groups"),
            content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: appState.getMyGroups().length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        contentPadding: EdgeInsets.only(left: 24),
                        title: Text(appState.getMyGroups()[index].name),
                        onTap: () => { appState.changeSelectedGroup(appState.getMyGroups()[index].id), Navigator.of(context).pop() },
                    );
                  },
                ),
              ),
            actions: <Widget>[
              FlatButton(
                padding: EdgeInsets.only(left: 14, right: 14),
                child: Text('Create new'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }));
  }

  Color _getColorForNumberBalance(String number) {
    if (double.parse(number) >= 0) {
      return Color.fromRGBO(0, 0, 0, 1);
    } else {
      return Color.fromRGBO(235, 64, 52, 1);
    }
  }

  _launchFeedbackUrl() async {
    const url = 'mailto:jens.wagner@fosforito.de?subject=[Feedback] Partido Client';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context, listen: false).initAppState();
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Partido'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.assessment)),
                Tab(icon: Icon(Icons.format_list_bulleted)),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.group),
                tooltip: "Groups",
                onPressed: _openGroupsDialog,
              ),
              PopupMenuButton<HomeMenuItem>(
                onSelected: (HomeMenuItem result) {
                  if (result == HomeMenuItem.account) {
                    _logout();
                  } else if (result == HomeMenuItem.about) {
                    // About dialog
                  } else if (result == HomeMenuItem.feedback) {
                    _launchFeedbackUrl();
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<HomeMenuItem>>[
                  const PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.account,
                    child: Text('Account (Logout)'),
                  ),
                  const PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.about,
                    child: Text('About Partido'),
                  ),
                  const PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.feedback,
                    child: Text('Send Feedback'),
                  ),
                ],
              )
            ],
          ),
          body: Consumer<AppState>(
            builder: (context, appState, child) {
              return TabBarView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          //leading: Icon(Icons.group, size: 30),
                          title: appState.getSelectedGroup().name != null ? Text('${appState.getSelectedGroup().name}') : Text('Welcome to Partido!'),
                          subtitle: appState.getSelectedGroup().status != null ? Text('${appState.getSelectedGroup().status}') : Text('Select or create a group to start!'),
                          trailing: appState.getSelectedGroup().status != null ? IconButton(icon: Icon(Icons.chevron_right), onPressed: () {},) : null,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 70),
                        itemCount: appState.getReport().balances.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text('${appState.getUserFromGroupById(appState.getReport().balances[index].user).username}'),
                                trailing: Text('${appState.getReport().balances[index].balance.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}',
                                  style: TextStyle(color: _getColorForNumberBalance(appState.getReport().balances[index].balance.toStringAsFixed(2))),
                                ),
                              )
                          );
                        },
                      ),
                    ],
                  ),
                  ListView.separated(
                    padding: EdgeInsets.only(bottom: 70),
                    separatorBuilder: (context, index) => Divider(
                      height: 0.0,
                    ),
                    itemCount: appState.getBills().length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title: Text('${appState.getBills()[index].description}'),
                        subtitle: Text('${appState.getUserFromGroupById(appState.getBills()[index].creator).username}'),
                        trailing: Text('${appState.getBills()[index].totalAmount.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillDetailsPage(bill: appState.getBills()[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create-bill');
            },
            tooltip: 'Create bill',
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

enum HomeMenuItem { account, about, feedback }
