import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class CreateBillPage extends StatefulWidget {
  CreateBillPage({Key key}) : super(key: key);

  @override
  _CreateBillPageState createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {

  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  final _formKey = GlobalKey<FormState>();
  String _description = null;
  String _amount = null;

  DateTime _selectedDate = DateTime.now();
  var dateController = new TextEditingController(text: "${DateTime.now().toLocal()}".split(' ')[0]);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2100, 12)
    );
    if (picked != null && picked != _selectedDate) {
      setState(() { _selectedDate = picked; });
    }
    dateController.text = "${_selectedDate.toLocal()}".split(' ')[0];
  }

  void _createBill() async {

    User mainUser = Provider.of<AppState>(context, listen: false).getCurrentUser(); // TODO: make paying user selectable via drop down in form
    double normalizedAmount = double.parse(_amount.toString().replaceAll(",", "."));

    Bill bill = new Bill();
    bill.description = _description;
    bill.totalAmount = normalizedAmount;
    bill.billingDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate);//_selectedDate.toString().substring(0, 19); // Format "2019-03-01 00:00:00"
    bill.parts = Provider.of<AppState>(context, listen: false).getSelectedGroup().users.length; // Every user pays the same amout but current user pays everything at first
    List<Split> splits = [];

    for (User user in Provider.of<AppState>(context, listen: false).getSelectedGroup().users) {
      Split split = new Split();
      if (user.id == mainUser.id) {
        split.main = true;
        split.paid = normalizedAmount;
      } else {
        split.main = false;
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
        Navigator.pop(context);
      }
    } catch (e) {
      logger.e("Failed to save bill", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create bill'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("From me\nFor all users in group"),
              SizedBox(height: 15.0),
              TextFormField(
                  onSaved: (value) => _description = value,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "Description")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: TextFormField(
                        onSaved: (value) => _amount = value,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: "Amount"),
                        textAlign: TextAlign.end,
                      ),
                  ),
                  Text("${Provider.of<AppState>(context, listen: false).getSelectedGroup().currency}",
                  style: TextStyle(height: 3.2),),
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
    );
  }
}
