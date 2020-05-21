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
          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  FlutterI18n.translate(context, "signup.success.title"),
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 16),
                I18nText("signup.success.success_notice"),
                SizedBox(height: 16),
                I18nText("signup.success.additional_info"),
                SizedBox(height: 16),
                MaterialButton(
                    minWidth: double.infinity,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(FlutterI18n.translate(context, "login.login_button"), style: TextStyle(fontWeight: FontWeight.w400)),
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
