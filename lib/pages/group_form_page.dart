import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/group.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';

class GroupFormPage extends StatefulWidget {
  final Group group;

  GroupFormPage({Key key, this.group}) : super(key: key);

  @override
  _GroupFormPageState createState() => _GroupFormPageState();
}

class _GroupFormPageState extends State<GroupFormPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  bool createNewGroupMode = true;

  String _name;
  String _description;
  String _currency;
  bool _joinModeActive = false;
  String _joinKey;

  TextEditingController groupNameController = new TextEditingController();
  TextEditingController groupDescriptionController =
      new TextEditingController();
  TextEditingController groupCurrencyController = new TextEditingController();

  @override
  void initState() {
    if (widget.group != null) {
      // edit existing group
      createNewGroupMode = false;
      groupNameController.text = widget.group.name;
      groupDescriptionController.text = widget.group.status;
      groupCurrencyController.text = widget.group.currency;
      _joinModeActive = widget.group.joinModeActive;
      _joinKey = widget.group.joinKey;
    }
    // else: create new group
    return super.initState();
  }

  void _createGroup() async {
    Group group = new Group(
        name: _name,
        status: _description,
        currency: _currency,
        joinModeActive: _joinModeActive,
        joinKey: _joinKey);
    try {
      HttpResponse<Group> response = await api.createGroup(group);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false)
            .changeSelectedGroup(response.data.id);
        navService.goBack();
        PartidoToast.showToast(
            msg: FlutterI18n.translate(
                context, "group_form.toast_group_created"));
      }
    } catch (e) {
      logger.e('Group creation failed', e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "group_form.toast_group_creation_failed"));
    }
  }

  void _updateGroup() async {
    Group updatedGroup = new Group(
        name: _name,
        status: _description,
        currency: _currency,
        joinModeActive: _joinModeActive,
        joinKey: _joinKey);
    try {
      HttpResponse<Group> response =
          await api.updateGroup(widget.group.id, updatedGroup);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack();
        PartidoToast.showToast(
            msg: FlutterI18n.translate(
                context, "group_form.toast_group_settings_saved"));
      }
    } catch (e) {
      logger.e('Saving group settings failed', e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "group_form.toast_group_settings_saving_failed"));
    }
  }

  void _onJoinModeActiveChanged(bool newValue) => setState(() {
        _joinModeActive = newValue;
        if (_joinModeActive) {
          // Do not add @. This character is used as separator in the combined joinKey (key@groupId)
          const chars =
              "ABCD?EFGH!JKLMNP_/QRSTUVWX+*YZabcdefghkmn'§pqrstuv%wxyz12345()6789";
          Random rnd = new Random.secure();
          String result = "";
          for (var i = 0; i < 12; i++) {
            result += chars[rnd.nextInt(chars.length)];
          }
          _joinKey = result;
        }
      });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LinearIcons.arrow_left),
          onPressed: () {
            navService.goBack();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: (createNewGroupMode)
            ? I18nText("group_form.create_group_title")
            : I18nText("group_form.group_settings_title"),
        actions: <Widget>[
          IconButton(
              icon: Icon(LinearIcons.check),
              tooltip: (createNewGroupMode)
                  ? FlutterI18n.translate(
                      context, "group_form.create_group_button")
                  : FlutterI18n.translate(
                      context, "group_form.save_changes_button"),
              onPressed: () {
                final form = _formKey.currentState;
                form.save();
                if (form.validate()) {
                  if (createNewGroupMode) {
                    _createGroup();
                  } else {
                    _updateGroup();
                  }
                }
              }),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(4),
          children: <Widget>[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 16, right: 0),
                    title: Text(
                      FlutterI18n.translate(context, "group_form.details"),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: groupNameController,
                          onSaved: (value) => _name = value,
                          decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, "group_form.group_name"),
                            prefixIcon: Icon(LinearIcons.users2),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) {
                              return FlutterI18n.translate(context,
                                  "group_form.group_name_empty_validation_error");
                            }
                            if (value.length > 255) {
                              return FlutterI18n.translate(context,
                                  "group_form.group_name_too_long_validation_error");
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: groupDescriptionController,
                          onSaved: (value) => _description = value,
                          decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, "group_form.group_description"),
                            prefixIcon: Icon(LinearIcons.pen3),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.length > 255) {
                              return FlutterI18n.translate(context,
                                  "group_form.group_description_too_long_validation_error");
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: groupCurrencyController,
                          onSaved: (value) => _currency = value,
                          decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, "group_form.currency"),
                            prefixIcon: Icon(LinearIcons.coin_dollar),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) {
                              return FlutterI18n.translate(context,
                                  "group_form.currency_empty_validation_error");
                            }
                            if (value.length > 3) {
                              return FlutterI18n.translate(context,
                                  "group_form.currency_too_long_validation_error");
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
                      FlutterI18n.translate(context, "group_form.join_mode"),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                      children: <Widget>[
                        CheckboxListTile(
                          title: I18nText("group_form.activate_join_mode"),
                          value: _joinModeActive,
                          onChanged: _onJoinModeActiveChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
