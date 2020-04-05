import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/group.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';

class CreateGroupPage extends StatefulWidget {
  CreateGroupPage({Key key}) : super(key: key);

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  String _name;
  String _description;
  String _currency;

  void _createGroup() async {
    Group group = new Group(name: _name, status: _description, currency: _currency);
    try {
      HttpResponse<Group> response = await api.createGroup(group);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).changeSelectedGroup(response.data.id);
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      logger.e('Group creation failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Partido'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 35, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Create group',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 15.0),
                  TextFormField(
                    onSaved: (value) => _name = value,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Group name"),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a group name';
                      }
                      if (value.length > 255) {
                        return 'Max. 255 characters allowed';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onSaved: (value) => _description = value,
                    decoration: InputDecoration(labelText: "Description (optional)"),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value.length > 255) {
                        return 'Max. 255 characters allowed';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onSaved: (value) => _currency = value,
                    decoration: InputDecoration(labelText: "Currency"),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a currency';
                      }
                      if (value.length > 255) {
                        return 'Max. 255 characters allowed';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.0),
                  MaterialButton(
                      minWidth: double.infinity,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Create group"),
                      onPressed: () {
                        final form = _formKey.currentState;
                        form.save();
                        if (form.validate()) {
                          _createGroup();
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
