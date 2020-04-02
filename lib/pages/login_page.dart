import 'package:flutter/material.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';

class LoginPage extends StatefulWidget {

  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
  bool _rememberMe = false;
  int rememberMeNumber = 0;

  void _login() async {
    HttpResponse<String> response = await api.login("$_email", "$_password", "$rememberMeNumber");
    if (response.response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, "/home");
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
      appBar: AppBar(
        title: Text('Partido'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Login',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 15.0),
              TextFormField(
                  onSaved: (value) => _email = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Email Address")),
              TextFormField(
                  onSaved: (value) => _password = value,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password")),
              CheckboxListTile(
                title: Text("Remember me"),
                value: _rememberMe,
                onChanged: _onRememberMeChanged,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 15.0),
              MaterialButton(
                  minWidth: double.infinity,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text("Login"),
                  onPressed: () {
                    // save the fields..
                    final form = _formKey.currentState;
                    form.save();
                    if (form.validate()) {
                      _login();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
