import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:partido_client/model/bill.dart';
import 'package:partido_client/model/split.dart';
import 'package:partido_client/model/user.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
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
  int _fromUserId;

  TextEditingController billDescriptionController = new TextEditingController();
  TextEditingController billAmountController = new TextEditingController();
  TextEditingController billDateController = new TextEditingController();
  TextEditingController billFromUserIdController = new TextEditingController();

  @override
  void initState() {
    billDescriptionController.text = widget.bill.description;
    billAmountController.text = widget.bill.totalAmount.toStringAsFixed(2);
    billDateController.text =  "${DateTime.parse(widget.bill.billingDate).toLocal()}".split(' ')[0];
    _selectedDate = DateTime.parse(widget.bill.billingDate); //widget.bill.billingDate
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

  void _updateBill() async {
    double normalizedAmount = double.parse(_amount.toString().replaceAll(",", "."));

    Bill updatedBill = new Bill();
    updatedBill.description = _description;
    updatedBill.totalAmount = normalizedAmount;
    updatedBill.billingDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate);
    updatedBill.parts = Provider.of<AppState>(context, listen: false).getSelectedGroup().users.length; // Every user pays the same amout but current user pays everything at first
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

    updatedBill.splits = splits;

    try {
      HttpResponse<Bill> response = await api.updateBill(updatedBill, Provider.of<AppState>(context, listen: false).getSelectedGroupId(), widget.bill.id);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack(); // close bill editing screen
        navService.goBack(); // close outdated bill details screen
        navService.push(MaterialPageRoute(builder: (context) => BillDetailsPage(bill: response.data)));
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
      Fluttertoast.showToast(msg: "An error occurred trying to delete the bill");
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
            onPressed: () { navService.goBack(); },
          ),
          FlatButton(
            child: Text('Yes, delete'),
            onPressed: _deleteBill,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _fromUserId = _fromUserId ?? Provider.of<AppState>(context, listen: false).getCurrentUser().id;
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
