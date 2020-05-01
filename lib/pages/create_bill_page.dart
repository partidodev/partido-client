import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/api/api.dart';
import 'package:partido_client/api/api_service.dart';
import 'package:partido_client/model/bill.dart';
import 'package:partido_client/model/split.dart';
import 'package:partido_client/model/user.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../navigation_service.dart';

class CreateBillPage extends StatefulWidget {
  CreateBillPage({Key key}) : super(key: key);

  @override
  _CreateBillPageState createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  int _fromUserId;
  String _description;
  String _amount;

  DateTime _selectedDate = DateTime.now();
  var dateController = new TextEditingController(
      text: "${DateTime.now().toLocal()}".split(' ')[0]);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2100, 12));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    dateController.text = "${_selectedDate.toLocal()}".split(' ')[0];
  }

  void _createBill() async {
    double normalizedAmount =
        double.parse(_amount.toString().replaceAll(",", "."));

    Bill bill = new Bill();
    bill.description = _description;
    bill.totalAmount = normalizedAmount;
    bill.billingDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate);
    bill.parts = Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()
        .users
        .length; // Every user pays the same amout but current user pays everything at first
    List<Split> splits = [];

    for (User user in Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()
        .users) {
      Split split = new Split();
      if (user.id == _fromUserId) {
        split.paid = normalizedAmount;
      } else {
        split.paid = 0.0;
      }
      split.debtor = user.id;
      split.partsOfBill = 1.0;
      splits.add(split);
    }

    bill.splits = splits;

    try {
      HttpResponse<Bill> response = await api.createBill(bill,
          Provider.of<AppState>(context, listen: false).getSelectedGroupId());
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack();
        Fluttertoast.showToast(msg: "New bill created");
      }
    } catch (e) {
      logger.e("Failed to save bill", e);
      Fluttertoast.showToast(msg: "An error occurred creating the bill");
    }
  }

  @override
  Widget build(BuildContext context) {
    _fromUserId = _fromUserId ?? Provider.of<AppState>(context, listen: false).getCurrentUser().id;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create bill'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("NOTICE: Currently all users in the group will have to pay the same amount. There will be the possibility to customize this behavior in a future release."),
                  SizedBox(height: 15.0),
                  DropdownButtonFormField<int>(
                    isDense: true,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: "From"),
                    value: _fromUserId,
                    onChanged: (int value) {
                      setState(() {
                        _fromUserId = value;
                      });
                    },
                    items: Provider.of<AppState>(context, listen: false)
                        .getSelectedGroup()
                        .users
                        .map((User user) {
                      return new DropdownMenuItem<int>(
                        value: user.id,
                        child: new Text(user.username),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    onSaved: (value) => _description = value,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Description"),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length > 255) {
                        return 'Max. 255 characters allowed';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TextFormField(
                          onSaved: (value) => _amount = value,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: "Amount"),
                          textAlign: TextAlign.end,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter the total amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      Text("${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}",
                        style: TextStyle(height: 3.2),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Date"),
                    controller: dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 15.0),
                  MaterialButton(
                      minWidth: double.infinity,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Create bill"),
                      onPressed: () {
                        // save the fields..
                        final form = _formKey.currentState;
                        form.save();
                        if (form.validate()) {
                          _createBill();
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
