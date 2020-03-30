import 'package:flutter/material.dart';
import 'package:partido_flutter/api.dart';
import 'package:partido_flutter/create_bill_page.dart';
import 'package:partido_flutter/home_page.dart';
import 'package:partido_flutter/login_page.dart';
import 'package:retrofit/dio.dart';

import 'api_service.dart';
import 'model/user.dart';

void main() async {
  // Set default home.
  Widget _defaultHome = new LoginPage();

  Api api = ApiService.getApi();

  // Check if User is already logged in (if valid cookie is existing) and
  // set first screen to HomePage or continue with LoginPage
  try {
    HttpResponse<User> _result = await api.getLoginStatus();
    if (_result.response.statusCode == 200) {
      _defaultHome = new HomePage();
    }
  } catch (e) { /* Error 401, ignore and continue with LoginPage */ }


  // Run the app!
  runApp(new MaterialApp(
    title: 'Partido',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    routes: {
      '/': (_) => _defaultHome,
      '/home': (_) => HomePage(),
      '/login': (_) => LoginPage(),
      '/create-bill': (_) => CreateBillPage(),
    },
  ));
}
