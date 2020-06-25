import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:partido_client/model/new_user.dart';
import 'package:partido_client/model/user.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:retrofit/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';

class SignupPage extends StatefulWidget {

  SignupPage({Key key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  bool formSaved = false;
  String _username;
  String _password;
  String _email;
  bool _acceptTerms = false;

  bool emailAlreadyRegistered = false;

  void _signup() async {

    NewUser newUser = new NewUser();
    newUser.username = _username;
    newUser.email = _email;
    newUser.password = _password;

    HttpResponse<User> response = await api.register(newUser);
    if (response.response.statusCode == 200) {
      navService.pushReplacementNamed("/signup-successful");
    } else if (response.response.statusCode == 412) {
      // HTTP status "precondition failed"; email is already registered
      emailAlreadyRegistered = true;
      _formKey.currentState.validate();
    }
  }

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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        FlutterI18n.translate(context, "signup.title"),
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
                                  onSaved: (value) => _username = value,
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "account.username"),
                                    prefixIcon: Icon(LinearIcons.user),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) { return FlutterI18n.translate(context, "account.username_empty_validation_error"); }
                                    if (value.length > 50) { return FlutterI18n.translate(context, "account.username_too_long_validation_error"); }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  onSaved: (value) => _email = value,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "account.email"),
                                    prefixIcon: Icon(LinearIcons.at_sign),
                                  ),
                                  validator: (value) {
                                    if (emailAlreadyRegistered) { return FlutterI18n.translate(context, "account.email_already_in_use_validation_error"); }
                                    if (value.isEmpty) { return FlutterI18n.translate(context, "account.email_empty_validation_error"); }
                                    if (!RegExp(r'^[a-zA-Z0-9\.]+@[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}$').hasMatch(value)) { return FlutterI18n.translate(context, "account.email_invalid_validation_error"); }
                                    if (value.length > 50) { return FlutterI18n.translate(context, "account.email_too_long_validation_error"); }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  onSaved: (value) => _password = value,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "account.password"),
                                    prefixIcon: Icon(LinearIcons.lock),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) { return FlutterI18n.translate(context, "signup.password_empty_validation_error"); }
                                    if (value.length > 100) { return FlutterI18n.translate(context, "signup.password_too_long_validation_error"); }
                                    if (value.length < 8) { return FlutterI18n.translate(context, "signup.password_too_short_validation_error"); }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "signup.password_confirmation"),
                                    prefixIcon: Icon(LinearIcons.rotation_lock),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) { return FlutterI18n.translate(context, "signup.password_empty_validation_error"); }
                                    if (value != _password) { return FlutterI18n.translate(context, "signup.password_confirmation_not_matching_validation_error"); }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                CheckboxListTile(
                                  title: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: FlutterI18n.translate(context, "signup.accept_privacy_text_before_link"), style: Theme.of(context).textTheme.bodyText2),
                                        TextSpan(
                                            text: FlutterI18n.translate(context, "signup.privacy_policy_link_text"),
                                            recognizer: new TapGestureRecognizer()..onTap = () {
                                              launch(FlutterI18n.translate(context, "signup.privacy_policy_link_url"));
                                            },
                                            style: TextStyle(color: Theme.of(context).primaryColor)),
                                        TextSpan(text: FlutterI18n.translate(context, "signup.accept_privacy_text_after_link"), style: Theme.of(context).textTheme.bodyText2),
                                      ],
                                    ),
                                  ),
                                  value: _acceptTerms,
                                  subtitle: (!_acceptTerms && formSaved) ? Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Text(
                                          FlutterI18n.translate(context, "signup.privacy_policy_not_accepted_error"),
                                        style: TextStyle(color: Color(0xFFe53935), fontSize: 12, fontWeight: FontWeight.w400),
                                      ),
                                  ) : null,
                                  onChanged: (bool value) => setState(() => _acceptTerms = value),
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                                SizedBox(height: 8),
                                MaterialButton(
                                    minWidth: double.infinity,
                                    color: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    child: Text(FlutterI18n.translate(context, "login.signup_button"), style: TextStyle(fontWeight: FontWeight.w400)),
                                    onPressed: () {
                                      emailAlreadyRegistered = false;
                                      final form = _formKey.currentState;
                                      form.save();
                                      setState(() => formSaved = true);
                                      if (form.validate() && _acceptTerms) {
                                        _signup();
                                      }
                                    }
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: FlatButton(
                                    child: Text(FlutterI18n.translate(context, "login.login_button"), style: TextStyle(fontWeight: FontWeight.w400)),
                                    onPressed: () {
                                      navService.goBack();
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
