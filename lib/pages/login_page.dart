import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  bool formSaved = false;
  bool loginFailed = false;
  bool tooManyLoginAttempts = false;
  bool accountNotVerified = false;
  String? _password;
  String? _email;
  bool? _rememberMe = false;
  int rememberMeNumber = 0;

  void _login() async {
    try {
      HttpResponse<String> response = await api.login("$_email", "$_password", "$rememberMeNumber");
      Provider.of<AppState>(context, listen: false).setRememberLoginStatus("$rememberMeNumber");
      if (response.response.statusCode == 200) {
        navService.pushReplacementNamed("/");
      } else if (response.response.statusCode == 429) {
        // HTTP status "too many requests"; blocked for 5 minutes
        setState(() {
          tooManyLoginAttempts = true;
        });
      } else if (response.response.statusCode == 423) {
        // HTTP status "locked"; account still not verified
        setState(() {
          accountNotVerified = true;
        });
      } else if (response.response.statusCode == 401) {
        // HTTP status "unauthorized"; invalid login credentials
        setState(() {
          loginFailed = true;
        });
      }
    } catch (w) {
      logger.w('Login failed', w);
      PartidoToast.showToast(msg: FlutterI18n.translate(context, "login.toast_login_failed"));
    }
  }

  void _onRememberMeChanged(bool? newValue) => setState(() {
        _rememberMe = newValue;
        if (_rememberMe! == true) {
          rememberMeNumber = 1;
        } else {
          rememberMeNumber = 0;
        }
      });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
          ),
          Center(
            child: SingleChildScrollView(
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 47),
                      child: Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 40,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          FlutterI18n.translate(context, "login.login_title"),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                  onSaved: (value) => _email = value,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const <String>[AutofillHints.username],
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "login.email"),
                                    prefixIcon: Icon(LinearIcons.at_sign),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return FlutterI18n.translate(context, "login.email_empty_validation_error");
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  onSaved: (value) => _password = value,
                                  obscureText: true,
                                  autofillHints: const <String>[AutofillHints.password],
                                  decoration:
                                  InputDecoration(
                                    labelText: FlutterI18n.translate(context, "login.password"),
                                    prefixIcon: Icon(LinearIcons.key),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return FlutterI18n.translate(context, "login.password_empty_validation_error");
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                (formSaved && loginFailed) ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                                      child: Text(
                                        FlutterI18n.translate(context,
                                            "login.login_failed_unauthorized"),
                                        style: TextStyle(
                                            color: MediaQuery.of(context).platformBrightness == Brightness.light
                                                ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                                : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )) : SizedBox(height: 0),
                                (formSaved && tooManyLoginAttempts) ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                                      child: Text(
                                        FlutterI18n.translate(context,
                                            "login.login_failed_too_many_attempts"),
                                        style: TextStyle(
                                            color: MediaQuery.of(context).platformBrightness == Brightness.light
                                                ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                                : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )) : SizedBox(height: 0),
                                (formSaved && accountNotVerified) ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                                      child: Text(
                                        FlutterI18n.translate(context,
                                            "login.login_failed_not_verified"),
                                        style: TextStyle(
                                            color: MediaQuery.of(context).platformBrightness == Brightness.light
                                                ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                                : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    )) : SizedBox(height: 0),
                                CheckboxListTile(
                                  title: I18nText("login.remember"),
                                  value: _rememberMe,
                                  onChanged: _onRememberMeChanged,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                                SizedBox(height: 8),
                                Row(children: <Widget>[
                                  Expanded(child: OutlinedButton(
                                    child: Text(
                                        FlutterI18n.translate(context, "login.signup_button"),
                                        style: TextStyle(fontWeight: FontWeight.w400),
                                    ),
                                    onPressed: () { navService.pushNamed('/signup'); },
                                  )),
                                  SizedBox(width: 8),
                                  Expanded(child: ElevatedButton(
                                    child: Text(
                                        FlutterI18n.translate(context, "login.login_button"),
                                        style: TextStyle(fontWeight: FontWeight.w400),
                                    ),
                                    onPressed: () {
                                      loginFailed = false;
                                      tooManyLoginAttempts = false;
                                      accountNotVerified = false;
                                      final form = _formKey.currentState;
                                      form!.save();
                                      setState(() => formSaved = true);
                                      if (form.validate()) {
                                        _login();
                                      }
                                    },
                                  )),
                                ]),
                                TextButton(
                                  onPressed: () { navService.pushNamed('/forgot-password'); },
                                  child: Text(
                                    FlutterI18n.translate(context, "login.forgot_password_button"),
                                    style: TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
