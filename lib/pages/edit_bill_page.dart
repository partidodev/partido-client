import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/bill.dart';
import 'package:partido_client/model/split.dart';
import 'package:partido_client/model/user.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../navigation_service.dart';
import 'bill_details_page.dart';

class EditBillPage extends StatefulWidget {
  final Bill bill;

  EditBillPage({Key key, @required this.bill}) : super(key: key);

  @override
  _EditBillPageState createState() => _EditBillPageState();
}

class _EditBillPageState extends State<EditBillPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  String _description;
  String _amount;
  DateTime _selectedDate;

  TextEditingController billDescriptionController = new TextEditingController();
  TextEditingController billAmountController = new TextEditingController();
  TextEditingController billDateController = new TextEditingController();
  TextEditingController billFromUserIdController = new TextEditingController();

  Map<int, bool> splitUsers = {};
  Map<int, TextEditingController> splitPaidControllers = {};
  Map<int, TextEditingController> splitPartsControllers = {};

  /// Initialize the split configuration for new bills.
  /// As default, all users in the group have to pay the same amount
  /// (1 part for every person) and the person creating the bill is as
  /// default the person who paid the bill.
  @override
  void initState() {
    billDescriptionController.text = widget.bill.description;
    billAmountController.text = widget.bill.totalAmount.toStringAsFixed(2);
    billDateController.text = "${DateTime.parse(widget.bill.billingDate).toLocal()}".split(' ')[0];
    _selectedDate = DateTime.parse(widget.bill.billingDate);

    Provider.of<AppState>(context, listen: false).getSelectedGroup().users.forEach((user) {
      bool splitFound = false;
      for(Split split in widget.bill.splits) {
        if (split.debtor == user.id) {
          splitFound = true;
          splitUsers.putIfAbsent(user.id, () => true);
          var splitPartsController = new TextEditingController(text: split.partsOfBill.toStringAsFixed(2));
          splitPartsControllers.putIfAbsent(user.id, () => splitPartsController);
          var splitPaidController = new TextEditingController(text: split.paid.toStringAsFixed(2));
          splitPaidControllers.putIfAbsent(user.id, () => splitPaidController);
          break;
        }
      }
      // if no split exists for an user, create defaults with zero-values
      if (!splitFound) {
        splitUsers.putIfAbsent(user.id, () => false);
        var splitPartsController = new TextEditingController(text: "0");
        splitPartsControllers.putIfAbsent(user.id, () => splitPartsController);
        var splitPaidController = new TextEditingController(text: "0.00");
        splitPaidControllers.putIfAbsent(user.id, () => splitPaidController);
      }
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
    billDateController.text = "${_selectedDate.toLocal()}".split(' ')[0];
  }

  double _normalizeDouble(String _doubleString) {
    return double.parse(_doubleString.replaceAll(",", "."));
  }

  void _updateBill() async {
    Bill updatedBill = new Bill();
    updatedBill.description = _description;
    updatedBill.totalAmount = _normalizeDouble(_amount);
    updatedBill.billingDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate);
    updatedBill.parts = 0;

    List<Split> splits = [];
    for (User user in Provider.of<AppState>(context, listen: false).getSelectedGroup().users) {
      if (splitUsers[user.id]) { // create splits for users only if they are involved in the bill
        updatedBill.parts += _normalizeDouble(splitPartsControllers[user.id].text);
        Split split = new Split();
        split.debtor = user.id;
        split.paid = _normalizeDouble(splitPaidControllers[user.id].text);
        split.partsOfBill = _normalizeDouble(splitPartsControllers[user.id].text);
        splits.add(split);
      }
    }
    updatedBill.splits = splits;

    try {
      HttpResponse<Bill> response = await api.updateBill(
          updatedBill,
          Provider.of<AppState>(context, listen: false).getSelectedGroupId(),
          widget.bill.id);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack(); // close bill editing screen
        navService.goBack(); // close outdated bill details screen
        navService.push(MaterialPageRoute(
            builder: (context) => BillDetailsPage(bill: response.data)));
        Fluttertoast.showToast(msg: "Bill updated");
      }
    } catch (e) {
      logger.e("Failed to save bill", e);
      Fluttertoast.showToast(msg: "An error occurred updating the bill");
    }
  }

  void _deleteBill() async {
    try {
      HttpResponse<String> response = await api.deleteBill(widget.bill.id);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack(); // close bill deleting dialog
        navService.goBack(); // close bill editing screen
        navService.goBack(); // close bill details screen
        Fluttertoast.showToast(msg: "Bill deleted");
      }
    } catch (e) {
      logger.e("Failed to delete bill", e);
      Fluttertoast.showToast(
          msg: "An error occurred trying to delete the bill");
    }
  }

  Future _openDeleteBillDialog() async {
    await showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Delete Bill"),
        content: Text("Are you sure, that you want to delete this bill?"),
        actions: <Widget>[
          FlatButton(
            child: Text('No, cancel'),
            onPressed: () {
              navService.goBack();
            },
          ),
          FlatButton(
            child: Text('Yes, delete'),
            onPressed: _deleteBill,
          ),
        ],
      ),
    );
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
        title: Text('Edit bill'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _openDeleteBillDialog,
            tooltip: 'Delete bill',
          ),
        ],
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
                    decoration: InputDecoration(labelText: "Description"),
                    controller: billDescriptionController,
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
                          controller: billAmountController,
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
                    controller: billDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 15.0),
                  MaterialButton(
                      minWidth: double.infinity,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Update bill"),
                      onPressed: () {
                        // save the fields..
                        final form = _formKey.currentState;
                        form.save();
                        if (form.validate()) {
                          _updateBill();
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
