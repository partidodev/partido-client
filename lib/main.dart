import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:partido_flutter/authentication_service.dart';
import 'package:partido_flutter/create_bill_page.dart';
import 'package:partido_flutter/home_page.dart';
import 'package:partido_flutter/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuthenticationService authenticationService = new AuthenticationService();

void main() async {
  // Set default home.
  Widget _defaultHome = new LoginPage();

  InterceptorsWrapper interceptors =
      InterceptorsWrapper(onRequest: (RequestOptions options) async {
    // Do something before request is sent

    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> cookies = preferences.getStringList('COOKIES');

    String cookiestring = "";
    for (String cookie in cookies) {
      List<String> parser = cookie.split(";");
      cookiestring = cookiestring + parser[0] + "; ";
    }

    options.headers.putIfAbsent("Cookie", () => cookiestring);

    return options; //continue
  }, onResponse: (Response response) async {
    if (response.headers['Set-Cookie'].isNotEmpty) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      List<String> cookies = preferences.getStringList('COOKIES');

      for (String header in response.headers['Set-Cookie']) {
        if (header.contains("remember-me")) {
          for (String cookie in cookies) {
            if (cookie.contains("remember-me")) {
              cookies.remove(cookie);
            }
          }
        }
        if (header.contains("JSESSIONID")) {
          for (String cookie in cookies) {
            if (cookie.contains("JSESSIONID")) {
              cookies.remove(cookie);
            }
          }
        }
        cookies.add(header);
      }

      preferences.clear();
      await preferences.setStringList("COOKIES", cookies);
    }

    return response;
  });

  Dio dio = new Dio();
  dio.interceptors.add(interceptors);

  bool _result = await authenticationService.autoLogin();
  if (_result) {
    _defaultHome = new HomePage();
  }

  // Run app!
  runApp(new MaterialApp(
    title: 'Partido',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    routes: {
      '/': (_) => _defaultHome,
      '/login': (_) => LoginPage(),
      '/create-bill': (_) => CreateBillPage(),
    },
  ));
}
