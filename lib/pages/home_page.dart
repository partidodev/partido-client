import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/group_join_body.dart';
import 'package:partido_client/pages/bill_details_page.dart';
import 'package:partido_client/pages/edit_group_page.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';

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

    GroupJoinBody groupJoinBody = new GroupJoinBody(userId: Provider.of<AppState>(context, listen: false).getCurrentUser().id, joinKey: groupKey);

    try {
      HttpResponse<String> response = await api.joinGroup(groupId, groupJoinBody);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).changeSelectedGroup(groupId);
        Provider.of<AppState>(context, listen: false).refreshAppState();
        Navigator.pop(context);
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
            title: Text("My Groups"),
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
                      Navigator.of(context).pop()
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Join existing'),
                onPressed: () {
                  Navigator.pop(context);
                  _openJoinGroupDialog();
                },

              ),
              FlatButton(
                child: Text('Create new'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/create-group');
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
            title: Text("Join Group"),
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
                      decoration: InputDecoration(labelText: "Join code"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the join code you recieved';
                        }
                        return null;
                      },
                    ),
                  ),

                ],),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Join'),
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
            title: Text("About Partido"),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 24),
                    title: Text("Imprint"),
                    onTap: () { _launchImprintUrl(); },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 24),
                    title: Text("Privacy Policy"),
                    onTap: () { _launchPrivacyPolicyUrl(); },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () { Navigator.pop(context); },
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

  _launchImprintUrl() async {
    const url = 'https://partido.fosforito.net/imprint/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPrivacyPolicyUrl() async {
    const url = 'https://partido.fosforito.net/privacy-policy/';
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
  Widget build(BuildContext context) {
    Provider.of<AppState>(context, listen: false).initAppState();
    return DefaultTabController(
      length: 2,
      child: Consumer<AppState>(builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Partido'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.assessment)),
                Tab(icon: Icon(Icons.format_list_bulleted)),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.group),
                tooltip: "Groups",
                onPressed: _openGroupsDialog,
              ),
              PopupMenuButton<HomeMenuItem>(
                onSelected: (HomeMenuItem result) {
                  if (result == HomeMenuItem.account) {
                    Navigator.pushNamed(context, '/account');
                  } else if (result == HomeMenuItem.about) {
                    _openAboutDialog();
                  } else if (result == HomeMenuItem.feedback) {
                    _launchFeedbackUrl();
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<HomeMenuItem>>[
                  const PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.account,
                    child: Text('Account'),
                  ),
                  const PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.about,
                    child: Text('About'),
                  ),
                  const PopupMenuItem<HomeMenuItem>(
                    value: HomeMenuItem.feedback,
                    child: Text('Feedback'),
                  ),
                ],
              )
            ],
          ),
          body: TabBarView(
            children: [
              ListView(
                padding: EdgeInsets.only(bottom: 70),
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          //leading: Icon(Icons.group, size: 30),
                          title: appState.getSelectedGroup().name != null
                              ? Text('${appState.getSelectedGroup().name}')
                              : Text('Welcome to Partido!'),
                          subtitle: appState.getSelectedGroup().status != null
                              ? Text('${appState.getSelectedGroup().status}')
                              : Text('Select or create a group to start!'),
                          trailing: appState.getSelectedGroup().status != null
                              ? IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  tooltip: 'Group settings',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditGroupPage(group: appState.getSelectedGroup()),
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
                                title: Text('Balances', style: TextStyle(fontWeight: FontWeight.w500)),
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
                                    title: Text('${appState.getUserFromGroupById(appState.getReport().balances[index].user).username}'),
                                    trailing: Text('${appState.getReport().balances[index].balance.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}',
                                      style: TextStyle(
                                        color: _getColorForNumberBalance(appState
                                            .getReport()
                                            .balances[index]
                                            .balance
                                            .toStringAsFixed(2)
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      if (appState.getSelectedGroup().name != null && appState.getSelectedGroup().joinModeActive)
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text('Join mode active', style: TextStyle(fontWeight: FontWeight.w500)),
                                leading: Icon(Icons.group_add, color: Colors.green),
                              ),
                              Divider(),
                              ListTile(title: Text('For security reasons, disable the group join mode when all users joined the group.')),
                              ListTile(
                                title: SelectableText("${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.content_copy),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: "${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}"
                                          ));
                                          Fluttertoast.showToast(msg: "Copied");
                                        }
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.share),
                                      onPressed: () {
                                        Share.share('Download the Partido app from Google Play Store https://play.google.com/apps/testing/net.fosforito.partido and join my group with the following code: ${appState.getSelectedGroup().joinKey}@${appState.getSelectedGroup().id}', subject: 'Join my group on Partido!');
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
                separatorBuilder: (context, index) => Divider(height: 0.0),
                itemCount: appState.getBills().length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('${appState.getBills()[index].description}'),
                    subtitle: Text('${appState.getUserFromGroupById(appState.getBills()[index].creator).username}'),
                    trailing: Text('${appState.getBills()[index].totalAmount.toStringAsFixed(2)} ${appState.getSelectedGroup().currency}'),
                    onTap: () {
                      Navigator.push(
                        context,
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
                Navigator.pushNamed(context, '/create-bill');
              }
            },
            tooltip: 'Create bill',
            child: Icon(Icons.add),
          ),
        );
      }),
    );
  }
}

enum HomeMenuItem { account, about, feedback }
