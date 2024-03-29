import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:partido_client/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation_service.dart';

class ApiService {
  static InterceptorsWrapper interceptors =
      InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
    // Do something before request is sent
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? cookies = preferences.getStringList('COOKIES');

    String cookiestring = "";
    if (cookies != null) {
      for (String cookie in cookies) {
        List<String> parser = cookie.split(";");
        cookiestring = cookiestring + parser[0] + "; ";
      }
      options.headers.putIfAbsent("Cookie", () => cookiestring);
    }

    return handler.next(options); //continue
  }, onResponse: (Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401 && response.requestOptions.path != "/login") {
      // Open login page if 401 unauthorized status is returned from server
      // but only if user is not already on /login page
      navService.pushNamedAndRemoveUntil("/login");
      print("redirected!");
    }
    if (response.headers['Set-Cookie'] != null &&
        response.headers['Set-Cookie']!.isNotEmpty) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      List<String>? cookies = preferences.getStringList('COOKIES');

      if (cookies == null) {
        cookies = [];
      }

      var toRemove = [];
      var toAdd = [];
        for (String header in response.headers['Set-Cookie']!) {
        if (header.contains("remember-me")) {
          cookies.forEach((cookie) {
            if (cookie.contains("remember-me")) {
              toRemove.add(cookie);
            }
          });
        }
        if (header.contains("JSESSIONID")) {
          cookies.forEach((cookie) {
            if (cookie.contains("JSESSIONID")) {
              toRemove.add(cookie);
            }
          });
        }
        toAdd.add(header);
      }

      cookies.removeWhere((cookie) => toRemove.contains(cookie));
      for (String cookie in toAdd) {
        cookies.add(cookie);
      }

      await preferences.setStringList("COOKIES", cookies);
    }
    return handler.next(response);
  });

  static Api getApi() {
    Dio dio = new Dio();
    //dio.interceptors.add(CookieManager(CookieJar()));
    dio.interceptors.add(interceptors);
    dio.options.validateStatus = (status) { return status! < 500; };
    return new Api(dio);
  }
}
