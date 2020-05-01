import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:partido_client/model/new_user.dart';
import 'package:partido_client/model/user.dart';
import 'package:retrofit/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_service.dart';
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

  void _signup() async {

    NewUser newUser = new NewUser();
    newUser.username = _username;
    newUser.email = _email;
    newUser.password = _password;

    HttpResponse<User> response = await api.register(newUser);
    if (response.response.statusCode == 200) {
      navService.pushReplacementNamed("/signup-successful");
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
                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign up',
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
                                  onSaved: (value) => _username = value,
                                  decoration: InputDecoration(labelText: "Username"),
                                  validator: (value) {
                                    if (value.isEmpty) { return 'Please enter an username'; }
                                    if (value.length > 50) { return 'Max. 50 characters allowed'; }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  onSaved: (value) => _email = value,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(labelText: "Email Address"),
                                  validator: (value) {
                                    if (value.isEmpty) { return 'Please enter your email address'; }
                                    if (RegExp(r'^[a-zA-Z0-9\\.]+@[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}$').hasMatch(value)) { return 'Please enter a valid email address'; }
                                    if (value.length > 50) { return 'Max. 50 characters allowed'; }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  onSaved: (value) => _password = value,
                                  obscureText: true,
                                  decoration: InputDecoration(labelText: "Password"),
                                  validator: (value) {
                                    if (value.isEmpty) { return 'Please enter a password'; }
                                    if (value.length > 100) { return 'Max. 100 characters allowed'; }
                                    if (value.length < 8) { return 'Min. 8 characters required'; }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(labelText: "Password confirmation"),
                                  validator: (value) {
                                    if (value.isEmpty) { return 'Please enter a password'; }
                                    if (value != _password) { return 'Passwords do not match'; }
                                    return null;
                                  },
                                ),
                                CheckboxListTile(
                                  title: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: 'I have read and accept the ', style: Theme.of(context).textTheme.body1),
                                        TextSpan(
                                            text: 'Privacy Policy',
                                            recognizer: new TapGestureRecognizer()..onTap = () {
                                              launch('https://partido.fosforito.net/privacy/');
                                            },
                                            style: TextStyle(color: Theme.of(context).primaryColor)),
                                        TextSpan(text: ' of Partido', style: Theme.of(context).textTheme.body1),
                                      ],
                                    ),
                                  ),
                                  value: _acceptTerms,
                                  subtitle: (!_acceptTerms && formSaved) ? Padding(
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      child: Text('You can use Partido only if you accept', style: TextStyle(color: Color(0xFFe53935), fontSize: 12))
                                  ) : null,
                                  onChanged: (bool value) => setState(() => _acceptTerms = value),
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                                SizedBox(height: 15.0),
                                MaterialButton(
                                    minWidth: double.infinity,
                                    color: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    child: Text("Sign up"),
                                    onPressed: () {
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
                                    padding: EdgeInsets.only(left: 14, right: 14),
                                    child: Text('Log in'),
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
