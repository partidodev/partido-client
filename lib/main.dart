import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:partido_client/pages/edit_account_page.dart';
import 'package:partido_client/pages/entry_form_page.dart';
import 'package:partido_client/pages/forgot_password_page.dart';
import 'package:partido_client/pages/group_form_page.dart';
import 'package:partido_client/pages/home_page.dart';
import 'package:partido_client/pages/login_page.dart';
import 'package:partido_client/pages/password_reset_requested_page.dart';
import 'package:partido_client/pages/signup_page.dart';
import 'package:partido_client/pages/signup_successful_page.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'navigation_service.dart';

void main() async {
  // Run the app!
  runApp(ChangeNotifierProvider(
      create: (context) => AppState(),
      child: new MaterialApp(
        title: 'Partido',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          canvasColor: Colors.white,
          fontFamily: 'Roboto',
          textTheme: defaultTextTheme(),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(235, 64, 52, 1)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(235, 64, 52, 1)),
            ),
            errorStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(235, 64, 52, 1),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
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
          '/create-entry': (_) => EntryFormPage(entry: null),
          '/create-group': (_) => GroupFormPage(group: null),
          '/account': (_) => EditAccountPage(),
          '/forgot-password': (_) => ForgotPasswordPage(),
          '/password-reset-requested': (_) => PasswordResetRequestedPage(),
        },
        supportedLocales: [
          Locale('de'),
          Locale('en'),
          Locale('es'),
          Locale('pt'),
          Locale('nb', 'NO'),
        ],
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(
              useCountryCode: true,
              fallbackFile: 'en',
              basePath: 'assets/i18n',
              decodeStrategies: [YamlDecodeStrategy()],
            ),
            missingTranslationHandler: (key, locale) {
              print("--- Missing Key: $key, languageCode: ${locale!.languageCode}");
            },
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      )));
}

TextTheme defaultTextTheme() {
  return TextTheme(
    headline1: TextStyle(fontWeight: FontWeight.w400),
    headline2: TextStyle(fontWeight: FontWeight.w400),
    headline3: TextStyle(fontWeight: FontWeight.w400),
    headline4: TextStyle(fontWeight: FontWeight.w400),
    headline5: TextStyle(fontWeight: FontWeight.w400),
    headline6: TextStyle(fontWeight: FontWeight.w400), // AppBar title, Dialog title, etc
    subtitle1: TextStyle(fontWeight: FontWeight.w300), // List tile titles
    subtitle2: TextStyle(fontWeight: FontWeight.w300),
    bodyText1: TextStyle(fontWeight: FontWeight.w400), // Emphasized text
    bodyText2: TextStyle(fontWeight: FontWeight.w300), // List leading/trailing, etc
  );
}
