import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/group.dart';
import 'package:partido_client/model/group_join_body.dart';
import 'package:partido_client/pages/entry_details_page.dart';
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
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Api api = ApiService.getApi();
  var logger = Logger(printer: PrettyPrinter());

  final _formKey = GlobalKey<FormState>();
  StateSetter? _setStateOfJoinGroupDialog;
  bool joinGroupFormSaved = false;
  bool groupToJoinNotFound = false;
  String? _groupJoinKey;

  NumberFormat? currencyFormatter;

  @override
  void initState() {
    Provider.of<AppState>(context, listen: false).initAppState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currencyFormatter = new NumberFormat(
        FlutterI18n.translate(context, "global.currency_format"),
        FlutterI18n.translate(context, "global.locale"),
    );
    return DefaultTabController(
      length: 2,
      child: Consumer<AppState>(builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Image(
              image: AssetImage('assets/images/logo-small.png'),
              height: 20,
            ),
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
              RefreshIndicator(
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(4, 4, 4, 70),
                  children: <Widget>[
                    appState.stateInitialized ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (appState.getSelectedGroup() == null)
                          buildWelcomeCard(context, appState.getMyGroups()),
                        if (appState.getSelectedGroup() != null && appState.getSelectedGroup()!.name != null)
                          buildGroupInfoCard(context, appState),
                        if (appState.getReport() != null && appState.getReport()!.balances!.length != 0)
                          buildGroupBalancesCard(context, appState),
                        if (appState.getSelectedGroup() != null && appState.getSelectedGroup()!.joinModeActive!)
                          buildJoinModeInfoCard(context, appState),
                      ],
                    ) : Column(
                      // Show loading indicator when opening app and hide all
                      // cards before we know what card will be displayed finally
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 45),
                          child: RefreshProgressIndicator(),
                        )
                      ],
                    ),
                  ],
                ),
                onRefresh: () async {
                  await appState.refreshAppState();
                  PartidoToast.showToast(msg: FlutterI18n.translate(context, 'home.group_refreshed_toast'));
                },
              ),
              RefreshIndicator(
                child: appState.getEntries().isNotEmpty
                    ? ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 70),
                  itemCount: appState.getEntries().length,
                  itemBuilder: (context, index) {
                    return buildEntryListItem(appState, index, context);
                  },
                ) : Center(child: I18nText("home.list_empty")),
                onRefresh: () async {
                  await appState.refreshAppState();
                  PartidoToast.showToast(msg: FlutterI18n.translate(context, 'home.group_refreshed_toast'));
                },
              ),
            ],
          ),
          floatingActionButton: appState.getSelectedGroup() != null
              ? FloatingActionButton(
                  onPressed: () {
                    if (appState.getSelectedGroup()!.name != null) {
                      navService.pushNamed('/create-entry');
                    }
                  },
                  tooltip: FlutterI18n.translate(context, "home.create_entry_tooltip"),
                  child: Icon(LinearIcons.plus),
                )
              : Container(),
        );
      }),
    );
  }

  /// Returns either a title like "Today", "Yesterday", "This week", "March 2019", etc.
  /// Or a tappable entry tile that opens a detailed view of the entry on tap.
  Card buildEntryListItem(AppState appState, int index, BuildContext context) {
    return Card(
      margin: appState.getProcessedEntryListTitles()![index + 1] != null
          ? EdgeInsets.only(bottom: 8)
          : EdgeInsets.zero,
      shape: Border(
        left: BorderSide(color: Color(0x0F000000), width: 1),
        top: BorderSide(color: Color(0x0F000000), width: 1),
        right: BorderSide(color: Color(0x0F000000), width: 1),
        bottom: index == appState.getEntries().length - 1 ||
                appState.getProcessedEntryListTitles()![index + 1] != null
            ? BorderSide(color: Color(0x0F000000), width: 1)
            : BorderSide(color: Color(0x0F000000), width: 0),
      ),
      child: Column(
        children: <Widget>[
          appState.getProcessedEntryListTitles()![index] != null
              ? Column(
                  children: [
                    appState.getProcessedEntryListTitles()![index]!.contains("#")
                        ? ListTile(
                            title: Text(
                            FlutterI18n.translate(context, "date." + appState.getProcessedEntryListTitles()![index]!.split("#")[0])
                                + " " + appState.getProcessedEntryListTitles()![index]!.split("#")[1],
                            style: TextStyle(fontSize: 18),
                          ))
                        : ListTile(
                            title: Text(
                            FlutterI18n.translate(context, "date." + appState.getProcessedEntryListTitles()![index]!),
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
                  appState.getAvailableEntryCategories()![
                      appState.getEntries()[index].category],
                  size: 27,
                ),
              ],
            ),
            title: Text('${appState.getEntries()[index].description}'),
            subtitle: Text('${appState.getUserFromGroupById(appState.getEntries()[index].creator!)!.username!}'),
            trailing: Text(
              '${currencyFormatter!.format(appState.getEntries()[index].totalAmount)} ${appState.getSelectedGroup()!.currency}',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              navService.push(
                MaterialPageRoute(
                  builder: (context) => EntryDetailsPage(entry: appState.getEntries()[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Creates the info card telling that the join mode of the current group is active.
  /// This card displays the coin code and some share buttons.
  Card buildJoinModeInfoCard(BuildContext context, AppState appState) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.only(left: 16, right: 0),
            title: Text(
              FlutterI18n.translate(context, "home.join_mode.title_enabled"),
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(LinearIcons.users_plus, color: Colors.green),
            trailing: IconButton(
              icon: Icon(
                LinearIcons.bubble_question,
                size: 20,
              ),
              tooltip: FlutterI18n.translate(context, "home.join_mode.faq_tooltip"),
              onPressed: () {
                _launchJoinModeFaqUrl(context);
              },
            ),
          ),
          Divider(),
          ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              title: I18nText("home.join_mode.info"),
          ),
          ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              title: I18nText("home.join_mode.security_notice"),
          ),
          ListTile(
            title: SelectableText("${appState.getSelectedGroup()!.joinKey}@${appState.getSelectedGroup()!.id}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(LinearIcons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: "${appState.getSelectedGroup()!.joinKey}@${appState.getSelectedGroup()!.id}"
                      ));
                      PartidoToast.showToast(msg: FlutterI18n.translate(context, "global.copied"));
                    }),
                IconButton(
                  icon: Icon(LinearIcons.share2),
                  onPressed: () {
                    Share.share(
                      '${FlutterI18n.translate(context, "home.join_mode.share.text")}\n\n'
                          '${appState.getSelectedGroup()!.joinKey}@${appState.getSelectedGroup()!.id}',
                      subject: FlutterI18n.translate(context, "home.join_mode.share.subject"),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the group balances card, showing who has to pay next
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
            itemCount: appState.getReport()!.balances!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(LinearIcons.user),
                title: Text('${appState.getUserFromGroupById(appState.getReport()!.balances![index].user!)!.username}'),
                trailing: Text(
                  '${currencyFormatter!.format(appState.getReport()!.balances![index].balance)} ${appState.getSelectedGroup()!.currency}',
                  style: TextStyle(
                    color: _getColorForNumberBalance(appState.getReport()!.balances![index].balance!.toStringAsFixed(2)),
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

  /// This card displays some custom information about the current group like
  /// name, status text and later maybe an image.
  /// This card is linked to the group settings page too.
  Card buildGroupInfoCard(BuildContext context, AppState appState) {
    return Card(
      child: ListTile(
          title: Text(
            '${appState.getSelectedGroup()!.name}',
            style: TextStyle(fontSize: 18),
          ),
          subtitle: appState.getSelectedGroup()!.status != ""
              ? Text('${appState.getSelectedGroup()!.status}')
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

  /// When logging in for the first time or on a new device,
  /// show the user some start options like group creation, group joining,
  /// opening already joined groups if any, etc.
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                I18nText("home.welcome.info"),
                SizedBox(height: 16),
                I18nText("home.welcome.info2"),
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

  /// Try to join a group
  /// Called only when submitting a join group form (dialog)
  void _joinGroup() async {
    String groupKey = _groupJoinKey!.split("@")[0];
    int groupId = int.parse(_groupJoinKey!.split("@")[1]);

    GroupJoinBody groupJoinBody = new GroupJoinBody(
        userId: Provider.of<AppState>(context, listen: false).getCurrentUser()!.id,
        joinKey: groupKey
    );

    try {
      HttpResponse<String> response = await api.joinGroup(groupId, groupJoinBody);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).changeSelectedGroup(groupId);
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack();
      } else if (response.response.statusCode == 404) {
        _setStateOfJoinGroupDialog!(() {
          groupToJoinNotFound = true;
        });
      }
    } catch (e) {
      logger.e("Failed to join group", e);
    }
  }

  /// Open the groups dialog, showing the current user's groups if any and
  /// options to create new or join existing groups.
  Future _openGroupsDialog() async {
    await showDialog(
        context: context,
        builder: (_) => Consumer<AppState>(builder: (context, appState, child) {
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
                    title: Text(appState.getMyGroups()[index].name!),
                    onTap: () => {
                      appState.changeSelectedGroup(appState.getMyGroups()[index].id!),
                      navService.goBack()
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                    FlutterI18n.translate(context, "home.groups_dialog.join_existing_button"),
                    style: TextStyle(fontWeight: FontWeight.w400)),
                onPressed: () {
                  navService.goBack();
                  _openJoinGroupDialog();
                },
              ),
              TextButton(
                child: Text(
                    FlutterI18n.translate(context, "home.groups_dialog.create_button"),
                    style: TextStyle(fontWeight: FontWeight.w400)),
                onPressed: () {
                  navService.pushReplacementNamed('/create-group');
                },
              ),
            ],
          );
        }));
  }

  /// Open the join group dialog with an input field for the join code
  Future _openJoinGroupDialog() async {
    setState(() => joinGroupFormSaved = false);
    await showDialog(
      context: context,
      builder: (context) {
        return Consumer<AppState>(builder: (context, appState, child) {
          return StatefulBuilder(
            builder: (context, setState) {
              _setStateOfJoinGroupDialog = setState;
              return AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
                title: I18nText("home.join_group_dialog.title"),
                content: Container(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  width: double.maxFinite,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        TextFormField(
                          onSaved: (value) => _groupJoinKey = value,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: FlutterI18n.translate(context, "home.join_group_dialog.join_code"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return FlutterI18n.translate(context, "home.join_group_dialog.join_code_empty_validation_error");
                            }
                            if (!RegExp(r'^.+@\d+$').hasMatch(value)) {
                              return FlutterI18n.translate(context, "home.join_group_dialog.join_code_invalid_validation_error");
                            }
                            return null;
                          },
                        ),
                        (joinGroupFormSaved && groupToJoinNotFound)
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  child: Text(
                                    FlutterI18n.translate(context, "home.join_group_dialog.join_code_not_found_validation_error"),
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
                      FlutterI18n.translate(context, "home.join_group_dialog.button_join"),
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    onPressed: () {
                      groupToJoinNotFound = false;
                      final form = _formKey.currentState;
                      form!.save();
                      setState(() => joinGroupFormSaved = true);
                      if (form.validate()) {
                        _joinGroup();
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

  Future _openAboutDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
          TextButton(
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

  Color? _getColorForNumberBalance(String number) {
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
        'mailto:jens.leon@wagner.pink?subject=[Feedback] Partido Client';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchJoinModeFaqUrl(BuildContext context) async {
    String url =  FlutterI18n.translate(context, "home.join_mode.faq_link");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

enum HomeMenuItem { account, about, feedback }
