import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:flutter/material.dart';

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
          return new SimpleDialog(
            title: new Text("My Groups"),
            children: <Widget>[
              new SimpleDialogOption(
                child: new Text("Standard"),
                onPressed: () {
                  Navigator.pop(
                      context,
                      Provider.of<AppState>(context, listen: false)
                          .changeSelectedGroup(1));
                },
              ),
              new SimpleDialogOption(
                child: new Text("Testgruppe"),
                onPressed: () {
                  Navigator.pop(
                      context,
                      Provider.of<AppState>(context, listen: false)
                          .changeSelectedGroup(2));
                },
              ),
              new SimpleDialogOption(
                child: new Text("Create new Group"),
                onPressed: () {
                  Navigator.pop(context, "");
                },
              )
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
                    // Feedback
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
                  ListView.builder(
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
                  ListView.separated(
                    padding: EdgeInsets.only(bottom: 70),
                    separatorBuilder: (context, index) => Divider(
                      height: 0.0,
                    ),
                    itemCount: appState.getBills().length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title:
                            Text('${appState.getBills()[index].description}'),
                        subtitle: Text(
                            '${appState.getUserFromGroupById(appState.getBills()[index].creator).username}'),
                        trailing: Text(
                            '${appState.getBills()[index].totalAmount.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}'),
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
