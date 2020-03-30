import 'package:flutter/material.dart';
import 'package:retrofit/dio.dart';

import 'api.dart';
import 'api_service.dart';

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

  void _login() async {
    HttpResponse<String> response = await api.login("$_email", "$_password");
    if (response.response.statusCode == 200) {
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0),
              Text(
                'Login',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                  onSaved: (value) => _email = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Email Address")),
              TextFormField(
                  onSaved: (value) => _password = value,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password")),
              SizedBox(height: 20.0),
              RaisedButton(child: Text("Login"), onPressed: () {
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
