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
import '../linear_icons_icons.dart';
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

  bool emailAlreadyRegistered = false;

  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();

  @override
  void initState() {
    User user = Provider.of<AppState>(context, listen: false).getCurrentUser();
    usernameController.text = user.username;
    emailController.text = user.email;
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LinearIcons.arrow_left),
          onPressed: () {
            navService.goBack();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: I18nText("account.title"),
        actions: <Widget>[
          IconButton(
              icon: Icon(LinearIcons.check),
              tooltip: FlutterI18n.translate(context, "account.save_button"),
              onPressed: () {
                emailAlreadyRegistered = false;
                final form = _formKey.currentState;
                form.save();
                if (form.validate()) {
                  _updateAccount();
                }
              })
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(4),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            FlutterI18n.translate(
                                context, "account.details"),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                onSaved: (value) => _username = value,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(
                                        context, "account.username")),
                                controller: usernameController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return FlutterI18n.translate(context,
                                        "account.username_empty_validation_error");
                                  }
                                  if (value.length > 50) {
                                    return FlutterI18n.translate(context,
                                        "account.username_too_long_validation_error");
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                onSaved: (value) => _email = value,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(
                                        context, "account.email")),
                                controller: emailController,
                                validator: (value) {
                                  if (emailAlreadyRegistered) {
                                    return FlutterI18n.translate(context,
                                        "account.email_already_in_use_validation_error");
                                  }
                                  if (value.isEmpty) {
                                    return FlutterI18n.translate(context,
                                        "account.email_empty_validation_error");
                                  }
                                  if (RegExp(
                                          r'^[a-zA-Z0-9\\.]+@[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}$')
                                      .hasMatch(value)) {
                                    return FlutterI18n.translate(context,
                                        "account.email_invalid_validation_error");
                                  }
                                  if (value.length > 50) {
                                    return FlutterI18n.translate(context,
                                        "account.email_too_long_validation_error");
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                onSaved: (value) => _oldPassword = value,
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(
                                        context, "account.password")),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return FlutterI18n.translate(context,
                                        "account.current_password_input_required");
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 16, right: 0),
                          title: Text(
                            FlutterI18n.translate(
                                context, "account.change_password.title"),
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              LinearIcons.bubble_question,
                              size: 20,
                            ),
                            onPressed: () {
                              PartidoToast.showToast(msg: FlutterI18n.translate(context, "account.change_password.description"));
                            },
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                onSaved: (value) => _newPassword = value,
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context,
                                        "account.change_password.new_password")),
                                validator: (value) {
                                  if (value.length > 100) {
                                    return FlutterI18n.translate(context,
                                        "account.change_password.new_password_too_long_validation_error");
                                  }
                                  if (value.length < 8 && value.length != 0) {
                                    return FlutterI18n.translate(context,
                                        "account.change_password.new_password_too_short_validation_error");
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context,
                                        "account.change_password.new_password_confirmation")),
                                validator: (value) {
                                  if (value != _newPassword) {
                                    return FlutterI18n.translate(context,
                                        "account.change_password.new_password_confirmation_not_matching_validation_error");
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: MaterialButton(
                        minWidth: double.infinity,
                        textColor: MediaQuery.of(context).platformBrightness == Brightness.light
                            ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                            : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                        child: Text(
                            FlutterI18n.translate(
                                context, "account.logout_tooltip"),
                            style: TextStyle(fontWeight: FontWeight.w400)),
                        onPressed: _openLogoutDialog),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        PartidoToast.showToast(
            msg: FlutterI18n.translate(
                context, "account.toast_account_settings_saved"));

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
          PartidoToast.showToast(
              msg:
                  FlutterI18n.translate(context, "account.toast_login_failed"));
        }
      } else if (response.response.statusCode == 412) {
        // HTTP status "precondition failed"; email is already in use
        emailAlreadyRegistered = true;
        _formKey.currentState.validate();
      }
    } catch (e) {
      logger.e("Failed to save account", e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "account.toast_error_updating_account"));
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
            child: Text(
                FlutterI18n.translate(
                    context, "account.logout_dialog.answer_no"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: () {
              navService.goBack();
            },
          ),
          FlatButton(
            child: Text(
                FlutterI18n.translate(
                    context, "account.logout_dialog.answer_yes"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}
