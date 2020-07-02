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
import '../linear_icons_icons.dart';
import '../navigation_service.dart';

import 'dart:ui';
import 'package:intl/intl.dart';

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

  NumberFormat currencyFormatter;

  @override
  void initState() {
    Provider.of<AppState>(context, listen: false).initAppState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currencyFormatter = new NumberFormat(
        FlutterI18n.translate(context, "global.currency_format"),
        FlutterI18n.translate(context, "global.locale"));
    return DefaultTabController(
      length: 2,
      child: Consumer<AppState>(builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Image(
              image: AssetImage('assets/images/logo-small.png'),
              height: 20,
            ), //I18nText('global.partido_title'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(LinearIcons.home4)),
                Tab(icon: Icon(LinearIcons.list)),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(LinearIcons.users2),
                tooltip: FlutterI18n.translate(context, "home.groups_tooltip"),
                onPressed: _openGroupsDialog,
              ),
              Transform.rotate(
                angle: 90 * 3.14159265359 / 180,
                child: PopupMenuButton<HomeMenuItem>(
                  icon: Icon(LinearIcons.ellipsis),
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
                ),
              ),
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
                      if (appState.getSelectedGroup().name == null)
                        buildWelcomeCard(context, appState.getMyGroups()),
                      if (appState.getSelectedGroup().name != null)
                        buildGroupInfoCard(appState, context),
                      if (appState.getSelectedGroup().name != null)
                        buildGroupBalancesCard(context, appState),
                      if (appState.getSelectedGroup().name != null &&
                          appState.getSelectedGroup().joinModeActive)
                        buildJoinModeInfoCard(context, appState),
                    ],
                  ),
                ],
              ),
              ListView.builder(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 70),
                //separatorBuilder: (context, index) => Divider(),
                itemCount: appState.getBills().length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: appState.getProcessedBillListTitles()[index+1] != null ? EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
                    shape: Border(
                      left: BorderSide(color: Color(0x0F000000), width: 1),
                      top: BorderSide(color: Color(0x0F000000), width: 1),
                      right: BorderSide(color: Color(0x0F000000), width: 1),
                      bottom: index == appState.getBills().length - 1
                          || appState.getProcessedBillListTitles()[index+1] != null
                          ? BorderSide(color: Color(0x0F000000), width: 1)
                          : BorderSide(color: Color(0x0F000000), width: 0),
                    ),
                    child: Column(
                      children: <Widget>[
                        appState.getProcessedBillListTitles()[index] != null
                            ? Column(
                                children: [
                                  appState.getProcessedBillListTitles()[index].contains("#")
                                  ? ListTile(title: Text(
                                      FlutterI18n.translate(context, "date." + appState.getProcessedBillListTitles()[index].split("#")[0])
                                          + " " + appState.getProcessedBillListTitles()[index].split("#")[1],
                                      style: TextStyle(fontSize: 18),
                                    ))
                                  : ListTile(title: Text(
                                      FlutterI18n.translate(context, "date." + appState.getProcessedBillListTitles()[index]),
                                      style: TextStyle(fontSize: 18),
                                    )),
                                  Divider(),
                                ],
                              )
                            : SizedBox(height: 0),
                        ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                appState.getAvailableBillCategories()[
                                    appState.getBills()[index].category],
                                size: 27,
                              ),
                            ],
                          ),
                          title:
                              Text('${appState.getBills()[index].description}'),
                          subtitle: Text(
                              '${appState.getUserFromGroupById(appState.getBills()[index].creator).username}'),
                          trailing: Text(
                            '${currencyFormatter.format(appState.getBills()[index].totalAmount)} ${appState.getSelectedGroup().currency}',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            navService.push(
                              MaterialPageRoute(
                                builder: (context) => BillDetailsPage(
                                    bill: appState.getBills()[index]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: appState.getSelectedGroup().name != null
              ? FloatingActionButton(
                  onPressed: () {
                    if (appState.getSelectedGroup().name != null) {
                      navService.pushNamed('/create-bill');
                    }
                  },
                  tooltip: FlutterI18n.translate(
                      context, "home.create_bill_tooltip"),
                  child: Icon(LinearIcons.plus),
                )
              : Container(),
        );
      }),
    );
  }

  Card buildJoinModeInfoCard(BuildContext context, AppState appState) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "home.join_mode.title_enabled"),
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(LinearIcons.users_plus, color: Colors.green),
          ),
          Divider(),
          ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              title: I18nText("home.join_mode.info")),
          ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              title: I18nText("home.join_mode.security_notice")),
          ListTile(
            title: SelectableText(
                "${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(LinearIcons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              "${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}"));
                      PartidoToast.showToast(
                          msg: FlutterI18n.translate(context, "global.copied"));
                    }),
                IconButton(
                  icon: Icon(LinearIcons.share2),
                  onPressed: () {
                    Share.share(
                        '${FlutterI18n.translate(context, "home.join_mode.share.text")} ${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}',
                        subject: FlutterI18n.translate(
                            context, "home.join_mode.share.subject"));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Card buildGroupBalancesCard(BuildContext context, AppState appState) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "home.balances.title"),
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(LinearIcons.balance, color: Colors.green),
          ),
          Divider(),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: appState.getReport().balances.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(LinearIcons.user),
                title: Text(
                    '${appState.getUserFromGroupById(appState.getReport().balances[index].user).username}'),
                trailing: Text(
                  '${currencyFormatter.format(appState.getReport().balances[index].balance)} ${appState.getSelectedGroup().currency}',
                  style: TextStyle(
                    color: _getColorForNumberBalance(appState
                        .getReport()
                        .balances[index]
                        .balance
                        .toStringAsFixed(2)),
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Card buildGroupInfoCard(AppState appState, BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(
            '${appState.getSelectedGroup().name}',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: appState.getSelectedGroup().status != ""
              ? Text('${appState.getSelectedGroup().status}')
              : null,
          trailing: Icon(LinearIcons.chevron_right),
          onTap: () {
            navService.push(
              MaterialPageRoute(
                builder: (context) =>
                    GroupFormPage(group: appState.getSelectedGroup()),
              ),
            );
          }),
    );
  }

  Card buildWelcomeCard(BuildContext context, List<Group> myGroups) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "home.welcome.title"),
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text(
                '${FlutterI18n.translate(context, "home.welcome.subtitle")}'),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(LinearIcons.landscape, color: Colors.green, size: 30),
              ],
            ),
          ),
          Divider(),
          if (myGroups.length != 0)
            ListTile(
              title: I18nText("home.welcome.open_my_groups"),
              trailing: Icon(LinearIcons.chevron_right),
              onTap: _openGroupsDialog,
            ),
          if (myGroups.length != 0) Divider(),
          ListTile(
            title: I18nText("home.welcome.create_new_group"),
            trailing: Icon(LinearIcons.chevron_right),
            onTap: () {
              navService.pushNamed('/create-group');
            },
          ),
          Divider(),
          ListTile(
            title: I18nText("home.welcome.join_existing_group"),
            trailing: Icon(LinearIcons.chevron_right),
            onTap: _openJoinGroupDialog,
          ),
        ],
      ),
    );
  }

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
                child: Text(
                    FlutterI18n.translate(
                        context, "home.groups_dialog.join_existing_button"),
                    style: TextStyle(fontWeight: FontWeight.w400)),
                onPressed: () {
                  navService.goBack();
                  _openJoinGroupDialog();
                },
              ),
              FlatButton(
                child: Text(
                    FlutterI18n.translate(
                        context, "home.groups_dialog.create_button"),
                    style: TextStyle(fontWeight: FontWeight.w400)),
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
                      decoration: InputDecoration(
                          labelText: FlutterI18n.translate(
                              context, "home.join_group_dialog.join_code")),
                      validator: (value) {
                        if (value.isEmpty) {
                          return FlutterI18n.translate(context,
                              "home.join_group_dialog.join_code_empty_validation_error");
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
                child: Text(FlutterI18n.translate(context, "global.cancel"),
                    style: TextStyle(fontWeight: FontWeight.w400)),
                onPressed: () {
                  navService.goBack();
                },
              ),
              FlatButton(
                child: Text(
                    FlutterI18n.translate(
                        context, "home.join_group_dialog.button_join"),
                    style: TextStyle(fontWeight: FontWeight.w400)),
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
            child: Text(FlutterI18n.translate(context, 'global.close'),
                style: TextStyle(fontWeight: FontWeight.w400)),
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
        return Color.fromRGBO(235, 64, 52, 1); // Color for light theme
      } else {
        return Color.fromRGBO(255, 99, 71, 1); // Color for dark theme
      }
    }
  }

  _launchHomepageUrl(BuildContext context) async {
    String url =
        FlutterI18n.translate(context, "home.about_dialog.homepage_url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchImprintUrl(BuildContext context) async {
    String url =
        FlutterI18n.translate(context, "home.about_dialog.imprint_url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPrivacyPolicyUrl(BuildContext context) async {
    String url =
        FlutterI18n.translate(context, "home.about_dialog.privacy_policy_url");
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
}

enum HomeMenuItem { account, about, feedback }
