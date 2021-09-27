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
  EditAccountPage({Key? key}) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  final _deleteAccountDialogFormKey = GlobalKey<FormState>();

  String? _username;
  String? _oldEmail;
  String? _email;
  String? _oldPassword;
  String? _newPassword;

  bool emailAlreadyRegistered = false;

  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();

  StateSetter? _setStateOfDeleteAccountDialog;
  bool deleteAccountFormSaved = false;
  bool _deleteAccountVerificationWordInvalid = false;
  bool _deleteAccountGroupsNotSettledUp = false;
  String? _deleteAccountVerificationWord;

  @override
  void initState() {
    User? user = Provider.of<AppState>(context, listen: false).getCurrentUser();
    usernameController.text = user!.username!;
    emailController.text = user.email!;
    _oldEmail = user.email;
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
                form!.save();
                if (form.validate()) {
                  _updateAccount();
                }
              }),
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
                            FlutterI18n.translate(context, "account.details"),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Divider(),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                onSaved: (value) => _username = value,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelText: FlutterI18n.translate(context, "account.username"),
                                  prefixIcon: Icon(LinearIcons.user),
                                ),
                                controller: usernameController,
                                validator: (value) {
                                  if (value!.isEmpty) {
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
                                decoration: InputDecoration(
                                  labelText: FlutterI18n.translate(context, "account.email"),
                                  prefixIcon: Icon(LinearIcons.at_sign),
                                ),
                                controller: emailController,
                                validator: (value) {
                                  if (emailAlreadyRegistered) {
                                    return FlutterI18n.translate(context, "account.email_already_in_use_validation_error");
                                  }
                                  if (value!.isEmpty) {
                                    return FlutterI18n.translate(context, "account.email_empty_validation_error");
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9\.]+@[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
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
                                autofillHints: const <String>[AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: FlutterI18n.translate(context, "account.password"),
                                  prefixIcon: Icon(LinearIcons.key),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return FlutterI18n.translate(context, "account.current_password_input_required");
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
                            FlutterI18n.translate(context, "account.change_password.title"),
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              LinearIcons.bubble_question,
                              size: 20,
                            ),
                            onPressed: () {
                              PartidoToast.showToast(
                                  msg: FlutterI18n.translate(context, "account.change_password.description"));
                            },
                          ),
                        ),
                        Divider(),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: AutofillGroup(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  onSaved: (value) => _newPassword = value,
                                  obscureText: true,
                                  autofillHints: const <String>[AutofillHints.newPassword],
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "account.change_password.new_password"),
                                    prefixIcon: Icon(LinearIcons.lock),
                                  ),
                                  validator: (value) {
                                    if (value!.length > 100) {
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
                                  autofillHints: const <String>[AutofillHints.newPassword],
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "account.change_password.new_password_confirmation"),
                                    prefixIcon: Icon(LinearIcons.rotation_lock),
                                  ),
                                  validator: (value) {
                                    if (value != _newPassword) {
                                      return FlutterI18n.translate(context, "account.change_password.new_password_confirmation_not_matching_validation_error");
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
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
                          title: I18nText("account.logout_tooltip"),
                          trailing: Icon(LinearIcons.chevron_right),
                          onTap: _openLogoutDialog,
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            FlutterI18n.translate(context, "account.delete"),
                            style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.light
                                ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                            ),
                          ),
                          trailing: Icon(
                            LinearIcons.chevron_right,
                            color: MediaQuery.of(context).platformBrightness == Brightness.light
                                ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                          ),
                          onTap: _openDeleteAccountDialog,
                        ),
                      ],
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

  void _updateAccount() async {
    NewUser updatedUser = new NewUser();
    updatedUser.username = _username;
    updatedUser.email = _email;
    updatedUser.password = _oldPassword;
    updatedUser.newPassword = _newPassword;

    try {
      HttpResponse<User> response = await api.updateUser(updatedUser,
          Provider.of<AppState>(context, listen: false).getCurrentUser()!.id!);
      if (response.response.statusCode == 200) {
        if (_oldEmail != _email) {
          _openVerificationRequiredDialog();
        } else {
          Provider.of<AppState>(context, listen: false).setCurrentUser(response.data);
          Provider.of<AppState>(context, listen: false).reloadSelectedGroup();
          navService.goBack();
          PartidoToast.showToast(msg: FlutterI18n.translate(context, "account.toast_account_settings_saved"));

          // Automatically re-login after changing account's settings
          try {
            var loginPassword;
            if (_newPassword!.length == 0) {
              loginPassword = _oldPassword;
            } else {
              loginPassword = _newPassword;
            }
            await api.login(
                "$_email",
                "$loginPassword",
                "${await Provider.of<AppState>(context, listen: false).getRememberLoginStatus()}"
            );
          } catch (e) {
            logger.e('Login failed', e);
            PartidoToast.showToast(msg: FlutterI18n.translate(context, "account.toast_login_failed"));
          }
        }
      } else if (response.response.statusCode == 412) {
        // HTTP status "precondition failed"; email is already in use
        emailAlreadyRegistered = true;
        _formKey.currentState!.validate();
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
      builder: (_) => AlertDialog(
        title: I18nText("account.logout_dialog.title"),
        content: I18nText("account.logout_dialog.question"),
        actions: <Widget>[
          TextButton(
            child: Text(
                FlutterI18n.translate(context, "account.logout_dialog.answer_no"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: () {
              navService.goBack();
            },
          ),
          TextButton(
            child: Text(
                FlutterI18n.translate(context, "account.logout_dialog.answer_yes"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Future _openDeleteAccountDialog() async {
    setState(() => deleteAccountFormSaved = false);
    await showDialog(
      context: context,
      builder: (context) {
        return Consumer<AppState>(builder: (context, appState, child) {
          return StatefulBuilder(
            builder: (context, setState) {
              _setStateOfDeleteAccountDialog = setState;
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
                title: I18nText("account.delete_dialog.title"),
                content: Container(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  width: double.maxFinite,
                  child: Form(
                    key: _deleteAccountDialogFormKey,
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        I18nText("account.delete_dialog.question"),
                        SizedBox(height: 16),
                        I18nText("account.delete_dialog.verification_info"),
                        SizedBox(height: 16),
                        TextFormField(
                          onSaved: (value) => _deleteAccountVerificationWord = value!,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: FlutterI18n.translate(context, "account.delete_dialog.verification_field_label"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return FlutterI18n.translate(context, "account.delete_dialog.field_empty_validation_error");
                            }
                            return null;
                          },
                        ),
                        (deleteAccountFormSaved && _deleteAccountVerificationWordInvalid)
                            ? Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: Text(
                                FlutterI18n.translate(context, "account.delete_dialog.wrong_verification_word_validation_error"),
                                style: TextStyle(
                                  color: MediaQuery.of(context).platformBrightness == Brightness.light
                                      ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                      : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ))
                            : SizedBox(height: 0),
                        (deleteAccountFormSaved && _deleteAccountGroupsNotSettledUp)
                            ? Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: Text(
                                FlutterI18n.translate(context, "account.delete_dialog.groups_not_settled_up_validation_error"),
                                style: TextStyle(
                                  color: MediaQuery.of(context).platformBrightness == Brightness.light
                                      ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                      : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ))
                            : SizedBox(height: 0),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      FlutterI18n.translate(context, "global.cancel"),
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    onPressed: () {
                      navService.goBack();
                    },
                  ),
                  TextButton(
                    child: Text(
                      FlutterI18n.translate(context, "account.delete_dialog.answer_delete"),
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    onPressed: () {
                      _deleteAccountVerificationWordInvalid = false;
                      _deleteAccountGroupsNotSettledUp = false;
                      final form = _deleteAccountDialogFormKey.currentState;
                      form!.save();
                      setState(() => deleteAccountFormSaved = true);
                      if (form.validate()) {
                        _deleteAccount();
                      }
                    },
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  void _deleteAccount() async {
    if (_deleteAccountVerificationWord != FlutterI18n.translate(context, "account.delete_dialog.verification_word")) {
      _setStateOfDeleteAccountDialog!(() {
        _deleteAccountVerificationWordInvalid = true;
      });
      return;
    }
    try {
      HttpResponse<String> response = await api.deleteUser(Provider.of<AppState>(context, listen: false).getCurrentUser()!.id!);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).clearAppState();
        navService.pushReplacementNamed("/login");
      } else if (response.response.statusCode == 412) {
        _setStateOfDeleteAccountDialog!(() {
          _deleteAccountGroupsNotSettledUp = true;
        });
      }
    } catch (e) {
      logger.e("Failed to delete account", e);
    }
  }

  Future _openVerificationRequiredDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: I18nText("account.verification_required_dialog.title"),
        content: I18nText("account.verification_required_dialog.info"),
        actions: <Widget>[
          TextButton(
            child: Text(
                FlutterI18n.translate(context, "account.verification_required_dialog.ok"),
                style: TextStyle(fontWeight: FontWeight.w400),
            ),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}
