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
  String _description;
  String _amount;

  DateTime _selectedDate = DateTime.now();
  var dateController = new TextEditingController(
      text: "${DateTime.now().toLocal()}".split(' ')[0]);

  Map<int, bool> splitUsers = {};
  Map<int, TextEditingController> splitPaidControllers = {};
  Map<int, TextEditingController> splitPartsControllers = {};

  /// Initialize the split configuration for new bills.
  /// As default, all users in the group have to pay the same amount
  /// (1 part for every person) and the person creating the bill is as
  /// default the person who paid the bill.
  @override
  void initState() {
    Provider.of<AppState>(context, listen: false).getSelectedGroup().users.forEach((user) {
      splitUsers.putIfAbsent(user.id, () => true);
      var splitPaidController = new TextEditingController(text: "0.00");
      splitPaidControllers.putIfAbsent(user.id, () => splitPaidController);
      var splitPartsController = new TextEditingController(text: "1");
      splitPartsControllers.putIfAbsent(user.id, () => splitPartsController);
    });
    return super.initState();
  }

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

  double _normalizeDouble(String _doubleString) {
    return double.parse(_doubleString.replaceAll(",", "."));
  }

  void _createBill() async {
    Bill bill = new Bill();
    bill.description = _description;
    bill.totalAmount = _normalizeDouble(_amount);
    bill.billingDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate);
    bill.parts = 0;

    List<Split> splits = [];
    for (User user in Provider.of<AppState>(context, listen: false).getSelectedGroup().users) {
      if (splitUsers[user.id]) { // create splits for users only if they are involved in the bill
        bill.parts += _normalizeDouble(splitPartsControllers[user.id].text);
        Split split = new Split();
        split.debtor = user.id;
        split.paid = _normalizeDouble(splitPaidControllers[user.id].text);
        split.partsOfBill = _normalizeDouble(splitPartsControllers[user.id].text);
        splits.add(split);
      }
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

  void _splitUserChanged(int userId, bool newValue) => setState(() {
        splitUsers[userId] = newValue;
      });

  @override
  Widget build(BuildContext context) {
    List<Widget> splitEditingRows = new List();
    Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()
        .users
        .forEach((user) {
      splitEditingRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: CheckboxListTile(
                title: Text(user.username),
                onChanged: (newValue) {
                  _splitUserChanged(user.id, newValue);
                },
                value: splitUsers[user.id],
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Flexible(
              child: TextFormField(
                controller: splitPartsControllers[user.id],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: "Parts"),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(width: 10.0),
            Flexible(
              child: TextFormField(
                controller: splitPaidControllers[user.id],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: "Paid"),
                textAlign: TextAlign.end,
              ),
            ),
            Text(
              "${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}",
              style: TextStyle(height: 3.2),
            ),
          ],
        )
      );
    });

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
                          onChanged: (value) {
                            splitPaidControllers[Provider.of<AppState>(context, listen: false).getCurrentUser().id].text = _normalizeDouble(value).toStringAsFixed(2);
                            setState(() {
                              _amount = value;
                            });
                          },
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: "Amount"),
                          textAlign: TextAlign.end,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter the total amount';
                            }
                            if (_normalizeDouble(value) <= 0) {
                              return 'Please enter a positive amount greater than 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      Text(
                        "${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}",
                        style: TextStyle(height: 3.2),
                      ),
                    ],
                  ),
                  Column(
                    children: splitEditingRows,
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
