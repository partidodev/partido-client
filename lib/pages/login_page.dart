import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../navigation_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
  bool _rememberMe = false;
  int rememberMeNumber = 0;

  void _login() async {
    try {
      HttpResponse<String> response =
          await api.login("$_email", "$_password", "$rememberMeNumber");
      Provider.of<AppState>(context, listen: false)
          .setRememberLoginStatus("$rememberMeNumber");
      if (response.response.statusCode == 200) {
        navService.pushReplacementNamed("/");
      }
    } catch (w) {
      logger.w('Login failed', w);
      PartidoToast.showToast(msg: FlutterI18n.translate(context, "login.toast_login_failed"));
    }
  }

  void _onRememberMeChanged(bool newValue) => setState(() {
        _rememberMe = newValue;
        if (_rememberMe) {
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
                  SizedBox(height: 15.0),
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
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                onSaved: (value) => _email = value,
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                    InputDecoration(labelText: FlutterI18n.translate(context, "login.email")),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return FlutterI18n.translate(context, "login.email_empty_validation_error");
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                onSaved: (value) => _password = value,
                                obscureText: true,
                                decoration:
                                    InputDecoration(labelText: FlutterI18n.translate(context, "login.password")),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return FlutterI18n.translate(context, "login.password_empty_validation_error");
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              CheckboxListTile(
                                title: I18nText("login.remember"),
                                value: _rememberMe,
                                onChanged: _onRememberMeChanged,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                              SizedBox(height: 10.0),
                              MaterialButton(
                                  minWidth: double.infinity,
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  child: I18nText("login.login_button"),
                                  onPressed: () {
                                    final form = _formKey.currentState;
                                    form.save();
                                    if (form.validate()) {
                                      _login();
                                    }
                                  }),
                              SizedBox(
                                width: double.infinity,
                                child: FlatButton(
                                  child: I18nText("login.signup_button"),
                                  onPressed: () {
                                    navService.pushNamed('/signup');
                                  },
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
        ],
      ),
    );
  }
}
