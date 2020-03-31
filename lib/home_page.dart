import 'package:retrofit/dio.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'api_service.dart';

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
    return new Scaffold(
      appBar: AppBar(
        //leading: new Container(),
        title: Text('Partido'),
        actions: <Widget>[
          PopupMenuButton<HomeMenuItem>(
            onSelected: (HomeMenuItem result) {
              if (result == HomeMenuItem.logout) {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<HomeMenuItem>>[
              const PopupMenuItem<HomeMenuItem>(
                value: HomeMenuItem.logout,
                child: Text('Logout'),
              ),
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Home / Dashboard',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-bill');
        },
        tooltip: 'Create bill',
        child: Icon(Icons.add),
      ),
    );
  }
}

enum HomeMenuItem { logout }
