import 'package:flutter/material.dart';
import 'package:partido_client/model/new_user.dart';
import 'package:partido_client/model/user.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';

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
      Navigator.pushReplacementNamed(context, "/signup-successful");
    }
  }

  void _onAcceptTermsChanged(bool newValue) => setState(() {
    _acceptTerms = newValue;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 35, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Sign up',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 15.0),
                  TextFormField(
                    onSaved: (value) => _username = value,
                    keyboardType: TextInputType.text,
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
                    title: Text("I accept the Terms and Conditions and the Privacy Policy of Partido"),
                    value: _acceptTerms,
                    subtitle: !_acceptTerms && formSaved? Text('You can use Partido only if you accept', style: TextStyle(color: Colors.red)) : null,
                    onChanged: _onAcceptTermsChanged,
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
                        formSaved = true;
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
                        Navigator.of(context).pop();
                      },
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
