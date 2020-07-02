import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';

import '../linear_icons_icons.dart';
import '../navigation_service.dart';

class SignupSuccessfulPage extends StatelessWidget {
  SignupSuccessfulPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: I18nText('signup.title'),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
          children: <Widget>[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      FlutterI18n.translate(context, "signup.success.title"),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FlutterI18n.translate(context, "signup.success.success_notice"),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          FlutterI18n.translate(context, "signup.success.additional_info"),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          FlutterI18n.translate(context, "signup.success.additional_info_2"),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: I18nText("signup.success.login_button"),
                    trailing: Icon(LinearIcons.chevron_right),
                    onTap: () {
                      navService.pushNamedAndRemoveUntil("/login");
                    }),
                ],
              ),
            ),
          ],
        ));
  }
}
