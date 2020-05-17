import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';

import '../navigation_service.dart';

class SignupSuccessfulPage extends StatelessWidget {

  SignupSuccessfulPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: I18nText('signup.success.title'),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20, 35, 20, 20),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  FlutterI18n.translate(context, "signup.success.title"),
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 15.0),
                I18nText("signup.success.success_notice"),
                SizedBox(height: 15.0),
                I18nText("signup.success.additional_info"),
                SizedBox(height: 15.0),
                MaterialButton(
                    minWidth: double.infinity,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: I18nText("login.login_button"),
                    onPressed: () {
                      navService.pushNamedAndRemoveUntil("/login");
                    }),
              ],
            ),
          ],
        )
    );
  }
}
