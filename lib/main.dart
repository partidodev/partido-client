import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:partido_client/api/api.dart';
import 'package:partido_client/pages/edit_account_page.dart';
import 'package:partido_client/pages/bill_form_page.dart';
import 'package:partido_client/pages/group_form_page.dart';
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
import 'navigation_service.dart';

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
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          buttonTheme: ButtonThemeData(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0)
              ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: InputBorder.none,
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFe53935))
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFe53935))
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
          accentColor: Colors.green,
          textSelectionHandleColor: Colors.green,
          toggleableActiveColor: Colors.green,
          highlightColor: Colors.green,
          indicatorColor: Colors.green,
          buttonTheme: ButtonThemeData(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0)
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: InputBorder.none,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFe53935))
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFe53935))
            ),
          ),
        ),
        navigatorKey: NavigationService.navigationKey,
        routes: {
          '/': (_) => _defaultHome,
          '/home': (_) => HomePage(),
          '/login': (_) => LoginPage(),
          '/signup': (_) => SignupPage(),
          '/signup-successful': (_) => SignupSuccessfulPage(),
          '/create-bill': (_) => BillFormPage(bill: null),
          '/create-group': (_) => GroupFormPage(group: null),
          '/account': (_) => EditAccountPage(),
        },
        localizationsDelegates: [
          FlutterI18nDelegate(translationLoader: FileTranslationLoader(
              useCountryCode: false,
              fallbackFile: 'en',
              basePath: 'assets/i18n',
              //forcedLocale: Locale('es'), // for locale testing
              decodeStrategies: [YamlDecodeStrategy()],
          )),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
      )
    )
  );
}
