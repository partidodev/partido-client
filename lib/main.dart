import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:partido_client/api/api.dart';
import 'package:partido_client/pages/create_bill_page.dart';
import 'package:partido_client/pages/create_group_page.dart';
import 'package:partido_client/pages/edit_account_page.dart';
import 'package:partido_client/pages/home_page.dart';
import 'package:partido_client/pages/login_page.dart';
import 'package:partido_client/pages/signup_page.dart';
import 'package:partido_client/pages/signup_successful_page.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:logger/logger.dart';

import 'api/api_service.dart';
import 'app_state.dart';
import 'model/user.dart';

void main() async {

  var logger = Logger(printer: PrettyPrinter());

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
  } catch (e) {
    logger.d("Opening login page. Session invalid or server problem?", e);
  }

  // Run the app!
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: new MaterialApp(
        title: 'Partido',
        theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.green,
          textSelectionHandleColor: Colors.green,
          toggleableActiveColor: Colors.green,
          highlightColor: Colors.green,
          indicatorColor: Colors.green,
          brightness: Brightness.dark,
        ),
        navigatorKey: NavigationService.navigationKey,
        routes: {
          '/': (_) => _defaultHome,
          '/home': (_) => HomePage(),
          '/login': (_) => LoginPage(),
          '/signup': (_) => SignupPage(),
          '/signup-successful': (_) => SignupSuccessfulPage(),
          '/create-bill': (_) => CreateBillPage(),
          '/create-group': (_) => CreateGroupPage(),
          '/account': (_) => EditAccountPage(),
        },
      )
    )
  );
}
