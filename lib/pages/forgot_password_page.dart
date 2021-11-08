import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  bool formSaved = false;
  bool error = false;
  String? _email;

  void _requestPasswordReset() async {
    try {
      HttpResponse<String> response = await api.requestPasswordReset("$_email");
      if (response.response.statusCode == 200) {
        navService.pushReplacementNamed("/password-reset-requested");
      } else {
        setState(() {
          error = true;
        });
      }
    } catch (w) {
      logger.w('Request to reset password failed', w);
      PartidoToast.showToast(msg: FlutterI18n.translate(context, "forgot_password.toast_password_reset_request_failed"));
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
              child: AutofillGroup(
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
                          FlutterI18n.translate(context, "forgot_password.title"),
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
                                  onSaved: (value) => _email = value,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const <String>[AutofillHints.username],
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, "login.email"),
                                    prefixIcon: Icon(LinearIcons.at_sign),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return FlutterI18n.translate(context, "login.email_empty_validation_error");
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                Row(children: <Widget>[
                                  Expanded(child: OutlinedButton(
                                    child: Text(
                                        FlutterI18n.translate(context, "login.login_button"),
                                        style: TextStyle(fontWeight: FontWeight.w400),
                                    ),
                                    onPressed: () { navService.goBack(); },
                                  )),
                                  SizedBox(width: 8),
                                  Expanded(child: ElevatedButton(
                                    child: Text(
                                        FlutterI18n.translate(context, "forgot_password.submit_button"),
                                        style: TextStyle(fontWeight: FontWeight.w400),
                                    ),
                                    onPressed: () {
                                      error = false;
                                      final form = _formKey.currentState;
                                      form!.save();
                                      setState(() => formSaved = true);
                                      if (form.validate()) {
                                        _requestPasswordReset();
                                      }
                                    },
                                  )),
                                ]),
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
          ),
        ],
      ),
    );
  }
}
