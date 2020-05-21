import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:partido_client/pages/edit_account_page.dart';
import 'package:partido_client/pages/bill_form_page.dart';
import 'package:partido_client/pages/group_form_page.dart';
import 'package:partido_client/pages/home_page.dart';
import 'package:partido_client/pages/login_page.dart';
import 'package:partido_client/pages/signup_page.dart';
import 'package:partido_client/pages/signup_successful_page.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'navigation_service.dart';

void main() async {

  // Run the app!
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: new MaterialApp(
        title: 'Partido',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          textTheme: defaultTextTheme(),
          appBarTheme: AppBarTheme(
            textTheme: defaultTextTheme(),
          ),
          buttonTheme: ButtonThemeData(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20),
              ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: InputBorder.none,
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                borderSide: BorderSide(color: Color(0xFFe53935))
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                borderSide: BorderSide(color: Color(0xFFe53935))
            ),
            errorStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
              side: BorderSide(
                color: Color(0x0F000000),
                width: 1,
              ),
            ),
          ),
          dividerTheme: DividerThemeData(
            thickness: 1,
            color: Color(0x0F000000),
            space: 0,
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
          fontFamily: 'Roboto',
          textTheme: defaultTextTheme(),
          appBarTheme: AppBarTheme(
            textTheme: defaultTextTheme(),
          ),
          buttonTheme: ButtonThemeData(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: InputBorder.none,
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                borderSide: BorderSide(color: Color(0xFFe53935))
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                borderSide: BorderSide(color: Color(0xFFe53935))
            ),
            errorStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
              side: BorderSide(
                color: Color(0x0F000000),
                width: 1,
              ),
            ),
          ),
          dividerTheme: DividerThemeData(
            thickness: 1,
            color: Color(0x0F000000),
            space: 0,
          ),

        ),
        navigatorKey: NavigationService.navigationKey,
        routes: {
          '/': (_) => HomePage(),
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
              decodeStrategies: [YamlDecodeStrategy()],
          )),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
      )
    )
  );
}

TextTheme defaultTextTheme() {
  return TextTheme(
    headline1: TextStyle(fontSize: 96, fontWeight: FontWeight.w400),
    headline2: TextStyle(fontSize: 60, fontWeight: FontWeight.w400),
    headline3: TextStyle(fontSize: 48, fontWeight: FontWeight.w400),
    headline4: TextStyle(fontSize: 34, fontWeight: FontWeight.w400),
    headline5: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.w400), // AppBar title, Dialog title, etc
    subtitle1: TextStyle(fontSize: 16, fontWeight: FontWeight.w300), // List tile titles
    subtitle2: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
    bodyText1: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), // Emphasized text
    bodyText2: TextStyle(fontSize: 14, fontWeight: FontWeight.w300), // List leading/trailing, etc
  );
}
