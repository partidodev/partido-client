import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/new_user.dart';
import 'package:partido_client/model/user.dart';
import 'package:partido_client/widgets/partido_toast.dart';
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
        PartidoToast.showToast(msg: FlutterI18n.translate(context, "account.toast_account_settings_saved"));

        try {
          var loginPassword;
          if (_newPassword.length == 0) {
            loginPassword = _oldPassword;
          } else {
            loginPassword = _newPassword;
          }
          await api.login("$_email", "$loginPassword",
              "${await Provider.of<AppState>(context, listen: false).getRememberLoginStatus()}");
        } catch (e) {
          logger.e('Login failed', e);
          PartidoToast.showToast(msg: FlutterI18n.translate(context, "account.toast_login_failed"));
        }
      }
    } catch (e) {
      logger.e("Failed to save account", e);
      PartidoToast.showToast(msg: FlutterI18n.translate(context, "account.toast_error_updating_account"));
    }
  }

  void _logout() async {
    await api.logout();
    navService.pushNamedAndRemoveUntil("/login");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("COOKIES");
    Provider.of<AppState>(context, listen: false).clearAppState();
  }

  Future _openLogoutDialog() async {
    await showDialog(
      context: context,
      child: AlertDialog(
        title: I18nText("account.logout_dialog.title"),
        content: I18nText("account.logout_dialog.question"),
        actions: <Widget>[
          FlatButton(
            child: I18nText("account.logout_dialog.answer_no"),
            onPressed: () {
              navService.goBack();
            },
          ),
          FlatButton(
            child: I18nText("account.logout_dialog.answer_yes"),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: I18nText("account.title"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _openLogoutDialog,
            tooltip: FlutterI18n.translate(context, "account.logout_tooltip"),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onSaved: (value) => _username = value,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: FlutterI18n.translate(context, "account.username")),
                    controller: usernameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return FlutterI18n.translate(context, "account.username_empty_validation_error");
                      }
                      if (value.length > 50) {
                        return FlutterI18n.translate(context, "account.username_too_long_validation_error");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    onSaved: (value) => _email = value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: FlutterI18n.translate(context, "account.email")),
                    controller: emailController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return FlutterI18n.translate(context, "account.email_empty_validation_error");
                      }
                      if (RegExp(r'^[a-zA-Z0-9\\.]+@[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}$').hasMatch(value)) {
                        return FlutterI18n.translate(context, "account.email_invalid_validation_error");
                      }
                      if (value.length > 50) {
                        return FlutterI18n.translate(context, "account.email_too_long_validation_error");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    onSaved: (value) => _oldPassword = value,
                    obscureText: true,
                    decoration: InputDecoration(labelText: FlutterI18n.translate(context, "account.password")),
                    validator: (value) {
                      if (value.isEmpty) {
                        return FlutterI18n.translate(context, "account.current_password_input_required");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  Text(FlutterI18n.translate(context, "account.change_password.title"),
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  I18nText("account.change_password.description"),
                  SizedBox(height: 16),
                  TextFormField(
                    onSaved: (value) => _newPassword = value,
                    obscureText: true,
                    decoration: InputDecoration(labelText: FlutterI18n.translate(context, "account.change_password.new_password")),
                    validator: (value) {
                      if (value.length > 100) {
                        return FlutterI18n.translate(context, "account.change_password.new_password_too_long_validation_error");
                      }
                      if (value.length < 8 && value.length != 0) {
                        return FlutterI18n.translate(context, "account.change_password.new_password_too_short_validation_error");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, "account.change_password.new_password_confirmation")),
                    validator: (value) {
                      if (value != _newPassword) {
                        return FlutterI18n.translate(context, "account.change_password.new_password_confirmation_not_matching_validation_error");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  MaterialButton(
                      minWidth: double.infinity,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: I18nText("account.save_button"),
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
