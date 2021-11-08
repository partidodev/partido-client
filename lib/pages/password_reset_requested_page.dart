import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';

import '../linear_icons_icons.dart';
import '../navigation_service.dart';

class PasswordResetRequestedPage extends StatelessWidget {
  PasswordResetRequestedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: I18nText('forgot_password.title'),
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
                      FlutterI18n.translate(context, "forgot_password.request_success.title"),
                      style: TextStyle(fontSize: 18),
                    ),
                    leading: Icon(LinearIcons.notification, color: Colors.green),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FlutterI18n.translate(context, "forgot_password.request_success.success_notice"),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          FlutterI18n.translate(context, "forgot_password.request_success.additional_info"),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          FlutterI18n.translate(context, "forgot_password.request_success.additional_info_2"),
                          style: TextStyle(fontSize: 16),
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
                    title: I18nText("forgot_password.request_success.login_button"),
                    trailing: Icon(LinearIcons.chevron_right),
                    onTap: () {
                      navService.pushNamedAndRemoveUntil("/login");},
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
