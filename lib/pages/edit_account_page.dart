import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/new_user.dart';
import 'package:partido_client/model/user.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../navigation_service.dart';

class EditAccountPage extends StatefulWidget {
  EditAccountPage({Key key}) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();

  String _username;
  String _email;
  String _oldPassword;
  String _newPassword;
  String _newPasswordVerification;

  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();

  @override
  void initState() {
    User user = Provider.of<AppState>(context, listen: false).getCurrentUser();
    usernameController.text = user.username;
    emailController.text = user.email;
    return super.initState();
  }

  void _updateAccount() async {
    NewUser updatedUser = new NewUser();
    updatedUser.username = _username;
    updatedUser.email = _email;
    updatedUser.password = _oldPassword;
    updatedUser.newPassword = _newPassword;

    try {
      HttpResponse<User> response = await api.updateUser(updatedUser,
          Provider.of<AppState>(context, listen: false).getCurrentUser().id);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false)
            .setCurrentUser(response.data);
        Provider.of<AppState>(context, listen: false).reloadSelectedGroup();
        navService.goBack();
        Fluttertoast.showToast(msg: "Settings saved");

        try {
          var loginPassword;
          if (_newPassword.length == 0) {
            loginPassword = _oldPassword;
          } else {
            loginPassword = _newPassword;
          }
          await api.login("$_email", "$loginPassword",
              "${await Provider.of<AppState>(context, listen: false).getRememberLoginStatus()}");
        } catch (w) {
          logger.w('Login failed', w);
          Fluttertoast.showToast(msg: "Login failed, please try again");
        }
      }
    } catch (e) {
      logger.e("Failed to save account", e);
      Fluttertoast.showToast(msg: "An error occurred updating the account");
    }
  }

  void _logout() async {
    try {
      await api.logout();
    } catch (e) {
      // Logout causes always a 401 (unauthorized) or 302 (redirect to /login).
      // That's why we just catch the error and open login page.
      navService.pushNamedAndRemoveUntil("/login");
    } finally {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.remove("COOKIES");
      Provider.of<AppState>(context, listen: false).clearAppState();
    }
  }

  Future _openLogoutDialog() async {
    await showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Logout"),
        content: Text("Do you want to log out?"),
        actions: <Widget>[
          FlatButton(
            child: Text('No, cancel'),
            onPressed: () {
              navService.goBack();
            },
          ),
          FlatButton(
            child: Text('Yes, logout'),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45.0),
        child: AppBar(
          title: Text('My account'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _openLogoutDialog,
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onSaved: (value) => _username = value,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: "Username"),
                    controller: usernameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter an username';
                      }
                      if (value.length > 255) {
                        return 'Max. 255 characters allowed';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onSaved: (value) => _email = value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: "Email"),
                    controller: emailController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a valid email address';
                      }
                      if (RegExp(
                              r'^[a-zA-Z0-9\\.]+@[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      if (value.length > 50) {
                        return 'Max. 50 characters allowed';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onSaved: (value) => _oldPassword = value,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password"),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  Text(
                    "Change password",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                      "Leave empty if you don't want to change your current password."),
                  SizedBox(height: 15.0),
                  TextFormField(
                    onSaved: (value) => _newPassword = value,
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: "New password (optional)"),
                    validator: (value) {
                      if (value.length > 100) {
                        return 'Max. 100 characters allowed';
                      }
                      if (value.length < 8 && value.length != 0) {
                        return 'Min. 8 characters required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onSaved: (value) => _newPasswordVerification = value,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "New password verification (optional)"),
                    validator: (value) {
                      if (value != _newPassword) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.0),
                  MaterialButton(
                      minWidth: double.infinity,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Save changes"),
                      onPressed: () {
                        // save the fields..
                        final form = _formKey.currentState;
                        form.save();
                        if (form.validate()) {
                          _updateAccount();
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
