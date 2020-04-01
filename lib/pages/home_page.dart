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

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context, listen: false).changeSelectedGroup(1);
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
              PopupMenuButton<HomeMenuItem>(
                onSelected: (HomeMenuItem result) {
                  if (result == HomeMenuItem.logout) {
                    _logout();
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<HomeMenuItem>>[
                  const PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.logout,
                    child: Text('Logout'),
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
                    itemCount: appState.getReport().balances.length,
                    itemBuilder: (context, index) {
                      return Card(child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('${appState.getUserFromGroupById(appState.getReport().balances[index].user).username}'),
                        trailing: Text('${appState.getReport().balances[index].balance.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}'),
                      ));
                    },
                  ),
                  ListView.separated(
                    separatorBuilder: (context, index) => Divider(height: 0.0,),
                    itemCount: appState.getBills().length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title: Text('${appState.getBills()[index].description}'),
                        subtitle: Text('${appState.getUserFromGroupById(appState.getBills()[index].creator).username}'),
                        trailing: Text('${appState.getBills()[index].totalAmount.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}'),
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

enum HomeMenuItem { logout }
