import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/group.dart';
import 'package:partido_client/model/group_join_body.dart';
import 'package:partido_client/pages/bill_details_page.dart';
import 'package:partido_client/pages/group_form_page.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../navigation_service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Api api = ApiService.getApi();
  var logger = Logger(printer: PrettyPrinter());

  final _formKey = GlobalKey<FormState>();
  String _groupJoinKey;

  void _joinGroup() async {
    String groupKey = _groupJoinKey.split("@")[0];
    int groupId = int.parse(_groupJoinKey.split("@")[1]);

    GroupJoinBody groupJoinBody = new GroupJoinBody(
        userId:
            Provider.of<AppState>(context, listen: false).getCurrentUser().id,
        joinKey: groupKey);

    try {
      HttpResponse<String> response =
          await api.joinGroup(groupId, groupJoinBody);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false)
            .changeSelectedGroup(groupId);
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack();
      }
    } catch (e) {
      logger.e("Failed to join grop", e);
    }
  }

  Future _openGroupsDialog() async {
    await showDialog(
        context: context,
        child: Consumer<AppState>(builder: (context, appState, child) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
            title: I18nText("home.groups_dialog.title"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appState.getMyGroups().length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    contentPadding: EdgeInsets.only(left: 24),
                    title: Text(appState.getMyGroups()[index].name),
                    onTap: () => {
                      appState.changeSelectedGroup(
                          appState.getMyGroups()[index].id),
                      navService.goBack()
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: I18nText('home.groups_dialog.join_existing_button'),
                onPressed: () {
                  navService.goBack();
                  _openJoinGroupDialog();
                },
              ),
              FlatButton(
                child: I18nText('home.groups_dialog.create_button'),
                onPressed: () {
                  navService.pushReplacementNamed('/create-group');
                },
              ),
            ],
          );
        }));
  }

  Future _openJoinGroupDialog() async {
    await showDialog(
        context: context,
        child: Consumer<AppState>(builder: (context, appState, child) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
            title: I18nText("home.join_group_dialog.title"),
            content: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      onSaved: (value) => _groupJoinKey = value,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: FlutterI18n.translate(context, "home.join_group_dialog.join_code")),
                      validator: (value) {
                        if (value.isEmpty) {
                          return FlutterI18n.translate(context, "home.join_group_dialog.join_code_empty_validation_error");
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: I18nText('global.cancel'),
                onPressed: () {
                  navService.goBack();
                },
              ),
              FlatButton(
                child: I18nText('home.join_group_dialog.button_join'),
                onPressed: () {
                  final form = _formKey.currentState;
                  form.save();
                  if (form.validate()) {
                    _joinGroup();
                  }
                },
              ),
            ],
          );
        }));
  }

  Future _openAboutDialog() async {
    await showDialog(
      context: context,
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
        title: I18nText("home.about_dialog.title"),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.only(left: 24),
                title: I18nText("home.about_dialog.homepage"),
                onTap: () {
                  _launchHomepageUrl(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 24),
                title: I18nText("home.about_dialog.imprint"),
                onTap: () {
                  _launchImprintUrl(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 24),
                title: I18nText("home.about_dialog.privacy_policy"),
                onTap: () {
                  _launchPrivacyPolicyUrl(context);
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: I18nText('global.close'),
            onPressed: () {
              navService.goBack();
            },
          ),
        ],
      ),
    );
  }

  Color _getColorForNumberBalance(String number) {
    if (double.parse(number) >= 0) {
      return null; // Use default text color
    } else {
      if (MediaQuery.of(context).platformBrightness == Brightness.light) {
        return Color.fromRGBO(235, 64, 52, 1); // Color for dark theme
      } else {
        return Color.fromRGBO(255, 99, 71, 1); // Color for dark theme
      }
    }
  }

  _launchHomepageUrl(BuildContext context) async {
    String url = FlutterI18n.translate(context, "home.about_dialog.homepage_url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchImprintUrl(BuildContext context) async {
    String url = FlutterI18n.translate(context, "home.about_dialog.imprint_url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPrivacyPolicyUrl(BuildContext context) async {
    String url = FlutterI18n.translate(context, "home.about_dialog.privacy_policy_url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchFeedbackUrl() async {
    const url =
        'mailto:jens.wagner@fosforito.de?subject=[Feedback] Partido Client';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    Provider.of<AppState>(context, listen: false).initAppState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Consumer<AppState>(builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: I18nText('global.partido_title'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.bubble_chart)),
                Tab(icon: Icon(Icons.format_list_bulleted)),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.group),
                tooltip: FlutterI18n.translate(context, "home.groups_tooltip"),
                onPressed: _openGroupsDialog,
              ),
              PopupMenuButton<HomeMenuItem>(
                onSelected: (HomeMenuItem result) {
                  if (result == HomeMenuItem.account) {
                    navService.pushNamed('/account');
                  } else if (result == HomeMenuItem.about) {
                    _openAboutDialog();
                  } else if (result == HomeMenuItem.feedback) {
                    _launchFeedbackUrl();
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<HomeMenuItem>>[
                  PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.account,
                    child: I18nText("home.menu.account"),
                  ),
                  PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.about,
                    child: I18nText('home.menu.about'),
                  ),
                  PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.feedback,
                    child: I18nText('home.menu.feedback'),
                  ),
                ],
              )
            ],
          ),
          body: TabBarView(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 70),
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          title: appState.getSelectedGroup().name != null
                              ? Text('${appState.getSelectedGroup().name}')
                              : I18nText("home.welcome.title"),
                          subtitle: groupCardSubtitle(context, appState.getSelectedGroup()),
                          trailing: appState.getSelectedGroup().name != null
                              ? IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  tooltip: FlutterI18n.translate(context,
                                      "home.welcome.group_settings_tooltip"),
                                  onPressed: () {
                                    navService.push(
                                      MaterialPageRoute(
                                        builder: (context) => GroupFormPage(
                                            group: appState.getSelectedGroup()),
                                      ),
                                    );
                                  },
                                )
                              : IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  onPressed: _openGroupsDialog,
                                ),
                        ),
                      ),
                      if (appState.getSelectedGroup().name != null)
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                    FlutterI18n.translate(
                                        context, "home.balances.title"),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                leading:
                                    Icon(Icons.equalizer, color: Colors.green),
                              ),
                              Divider(),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: appState.getReport().balances.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text(
                                        '${appState.getUserFromGroupById(appState.getReport().balances[index].user).username}'),
                                    trailing: Text(
                                      '${appState.getReport().balances[index].balance.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}',
                                      style: TextStyle(
                                        color: _getColorForNumberBalance(
                                            appState
                                                .getReport()
                                                .balances[index]
                                                .balance
                                                .toStringAsFixed(2)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      if (appState.getSelectedGroup().name != null &&
                          appState.getSelectedGroup().joinModeActive)
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                    FlutterI18n.translate(context,
                                        "home.join_mode.title_enabled"),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                leading:
                                    Icon(Icons.group_add, color: Colors.green),
                              ),
                              Divider(),
                              ListTile(
                                  title: I18nText(
                                      "home.join_mode.security_notice")),
                              ListTile(
                                title: SelectableText(
                                    "${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.content_copy),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text:
                                                  "${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}"));
                                          PartidoToast.showToast(
                                              msg: FlutterI18n.translate(
                                                  context, "global.copied"));
                                        }),
                                    IconButton(
                                      icon: Icon(Icons.share),
                                      onPressed: () {
                                        Share.share(
                                            '${FlutterI18n.translate(context, "home.join_mode.share.text")} ${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}',
                                            subject: FlutterI18n.translate(
                                                context,
                                                "home.join_mode.share.subject"));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              ListView.separated(
                padding: EdgeInsets.only(bottom: 70),
                separatorBuilder: (context, index) => Divider(height: 0),
                itemCount: appState.getBills().length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('${appState.getBills()[index].description}'),
                    subtitle: Text(
                        '${appState.getUserFromGroupById(appState.getBills()[index].creator).username}'),
                    trailing: Text(
                        '${appState.getBills()[index].totalAmount.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}'),
                    onTap: () {
                      navService.push(
                        MaterialPageRoute(
                          builder: (context) =>
                              BillDetailsPage(bill: appState.getBills()[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (appState.getSelectedGroup().name != null) {
                navService.pushNamed('/create-bill');
              }
            },
            tooltip: FlutterI18n.translate(context, "home.create_bill_tooltip"),
            child: Icon(Icons.add),
          ),
        );
      }),
    );
  }

  Text groupCardSubtitle(BuildContext context, Group selectedGroup) {
    if (selectedGroup.name != null) {
      if (selectedGroup.status == "") {
        return null;
      }
      return Text('${selectedGroup.status}');
    } else {
      return Text('${FlutterI18n.translate(context, "home.welcome.subtitle")}');
    }
  }
}

enum HomeMenuItem { account, about, feedback }
