import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/bill.dart';
import 'package:partido_client/model/split.dart';
import 'package:partido_client/model/user.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';
import 'bill_details_page.dart';

class BillFormPage extends StatefulWidget {
  final Bill bill;

  BillFormPage({Key key, @required this.bill}) : super(key: key);

  @override
  _BillFormPageState createState() => _BillFormPageState();
}

class _BillFormPageState extends State<BillFormPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  NumberFormat currencyFormatter;
  NumberFormat partFormatter;
  DateFormat dateFormatter;

  final _formKey = GlobalKey<FormState>();
  bool createNewBillMode = true;
  bool initDone = false;
  bool formSaved = false;

  String _category;
  String _description;
  String _amount;
  DateTime _selectedDate;

  TextEditingController billDescriptionController = new TextEditingController();
  TextEditingController billAmountController = new TextEditingController();
  TextEditingController billDateController = new TextEditingController();
  TextEditingController billCategoryController = new TextEditingController();

  Map<int, bool> splitUsers = {};
  Map<int, TextEditingController> splitPaidControllers = {};
  Map<int, TextEditingController> splitPartsControllers = {};

  /// we use a custom init method here instead of overriding the
  /// initState method because localization of currency and date formats
  /// does not work correctly in it.
  void init(BuildContext context) {
    if (initDone) {
      return;
    }
    dateFormatter =
        new DateFormat(FlutterI18n.translate(context, "global.date_format"));
    currencyFormatter = new NumberFormat(
        FlutterI18n.translate(context, "global.currency_format"),
        FlutterI18n.translate(context, "global.locale"));
    partFormatter = new NumberFormat(
        FlutterI18n.translate(context, "global.part_format"),
        FlutterI18n.translate(context, "global.locale"));

    if (widget.bill == null) {
      _category = "Unkategorisiert";
      // create new bill
      Provider.of<AppState>(context, listen: false)
          .getSelectedGroup()
          .users
          .forEach((user) {
        splitUsers.putIfAbsent(user.id, () => true);
        var splitPaidController =
            new TextEditingController(text: currencyFormatter.format(0.00));
        splitPaidControllers.putIfAbsent(user.id, () => splitPaidController);
        var splitPartsController = new TextEditingController(text: "1");
        splitPartsControllers.putIfAbsent(user.id, () => splitPartsController);
      });
      if (_selectedDate == null) {
        _selectedDate = DateTime.now();
      }
    } else {
      // edit existing bill
      createNewBillMode = false;
      billDescriptionController.text = widget.bill.description;
      if (widget.bill.category != null) {
        _category = widget.bill.category;
      } else {
        _category = "Unkategorisiert";
      }
      billAmountController.text =
          currencyFormatter.format(widget.bill.totalAmount);
      if (_selectedDate == null) {
        _selectedDate = DateTime.parse(widget.bill.billingDate);
      }

      Provider.of<AppState>(context, listen: false)
          .getSelectedGroup()
          .users
          .forEach((user) {
        bool splitFound = false;
        for (Split split in widget.bill.splits) {
          if (split.debtor == user.id) {
            splitFound = true;
            splitUsers.putIfAbsent(user.id, () => true);
            var splitPartsController = new TextEditingController(
                text: partFormatter.format(split.partsOfBill));
            splitPartsControllers.putIfAbsent(
                user.id, () => splitPartsController);
            var splitPaidController = new TextEditingController(
                text: currencyFormatter.format(split.paid));
            splitPaidControllers.putIfAbsent(
                user.id, () => splitPaidController);
            break;
          }
        }
        // if no split exists for an user, create defaults with zero-values
        if (!splitFound) {
          splitUsers.putIfAbsent(user.id, () => false);
          var splitPartsController = new TextEditingController(text: "0");
          splitPartsControllers.putIfAbsent(
              user.id, () => splitPartsController);
          var splitPaidController =
              new TextEditingController(text: currencyFormatter.format(0.00));
          splitPaidControllers.putIfAbsent(user.id, () => splitPaidController);
        }
      });
    }
    billDateController.text = dateFormatter.format(_selectedDate);
    billCategoryController.text = _category;
    initDone = true;
  }

  @override
  Widget build(BuildContext context) {
    init(context);
    List<Widget> splitEditingRows = new List();
    Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()
        .users
        .forEach((user) {
      splitEditingRows.add(Row(
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
            flex: 44, // %
          ),
          SizedBox(width: 8),
          Flexible(
            child: TextFormField(
              controller: splitPartsControllers[user.id],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, "bill_form.parts")),
              textAlign: TextAlign.end,
            ),
            flex: 28, // %
          ),
          SizedBox(width: 8),
          Flexible(
            child: TextFormField(
              controller: splitPaidControllers[user.id],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  suffixText: Provider.of<AppState>(context, listen: false)
                      .getSelectedGroup()
                      .currency,
                  labelText: FlutterI18n.translate(context, "bill_form.paid")),
              textAlign: TextAlign.end,
            ),
            flex: 28, // %
          ),
        ],
      ));
      splitEditingRows.add(SizedBox(height: 8));
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LinearIcons.arrow_left),
          onPressed: () {
            navService.goBack();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: (createNewBillMode)
            ? I18nText('bill_form.create_bill_title')
            : I18nText('bill_form.edit_bill_title'),
        actions: (createNewBillMode)
            ? <Widget>[
                IconButton(
                    icon: Icon(LinearIcons.check),
                    tooltip: FlutterI18n.translate(
                        context, "bill_form.create_bill_button"),
                    onPressed: () {
                      // save the fields..
                      final form = _formKey.currentState;
                      form.save();
                      setState(() => formSaved = true);
                      if (form.validate() && sumOfActiveSplitsEqualsAmount()) {
                        _createBill();
                      }
                    })
              ] : <Widget>[
                IconButton(
                    icon: Icon(LinearIcons.check),
                    tooltip: FlutterI18n.translate(
                        context, "bill_form.update_bill_button"),
                    onPressed: () {
                      // save the fields..
                      final form = _formKey.currentState;
                      form.save();
                      setState(() => formSaved = true);
                      if (form.validate() && sumOfActiveSplitsEqualsAmount()) {
                        _updateBill();
                      }
                    })
              ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          "Details",
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
                              onSaved: (value) => _description = value,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(LinearIcons.pen3),
                                  labelText: FlutterI18n.translate(
                                      context, "bill_form.description")),
                              controller: billDescriptionController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return FlutterI18n.translate(context,
                                      "bill_form.description_empty_validation_error");
                                }
                                if (value.length > 255) {
                                  return FlutterI18n.translate(context,
                                      "bill_form.description_too_long_validation_error");
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              decoration: InputDecoration(
                                  prefixIcon: Icon(LinearIcons.tag),
                                  suffixIcon: Icon(LinearIcons.chevron_down, size: 20,),
                                  labelText: "Category"),
                              controller: billCategoryController,
                              readOnly: true,
                              onTap: () => _selectCategory(context),
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: TextFormField(
                                    onSaved: (value) => _amount = value,
                                    onChanged: (value) {
                                      if (createNewBillMode) {
                                        splitPaidControllers[Provider.of<AppState>(
                                            context,
                                            listen: false)
                                            .getCurrentUser()
                                            .id]
                                            .text =
                                            currencyFormatter
                                                .format(_normalizeDouble(value));
                                        setState(() {
                                          _amount = value;
                                        });
                                      }
                                    },
                                    keyboardType: TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(LinearIcons.bag_dollar),
                                      labelText: FlutterI18n.translate(
                                          context, "bill_form.amount"),
                                      suffixText: Provider.of<AppState>(context,
                                          listen: false)
                                          .getSelectedGroup()
                                          .currency,
                                    ),
                                    textAlign: TextAlign.end,
                                    controller: billAmountController,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return FlutterI18n.translate(context,
                                            "bill_form.amount_empty_validation_error");
                                      }
                                      if (_normalizeDouble(value) <= 0) {
                                        return FlutterI18n.translate(context,
                                            "bill_form.amount_not_positive_validation_error");
                                      }
                                      return null;
                                    },
                                  ),
                                  flex: 50, // %
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(LinearIcons.calendar_31),
                                        labelText: FlutterI18n.translate(
                                            context, "bill_form.date")),
                                    controller: billDateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                  ),
                                  flex: 50, // %
                                ),
                              ],
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
                          "Splits",
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            LinearIcons.bubble_question,
                            size: 20,
                          ),
                          tooltip: "Open Split FAQ",
                          onPressed: () {
                            _launchFaqUrl(context);
                          },
                        ),
                      ),
                      Divider(),
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 8),
                            Column(
                              children: splitEditingRows,
                            ),
                            SizedBox(height: 8),
                            (formSaved && !sumOfActiveSplitsEqualsAmount())
                                ? Padding(
                                    padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                                    child: Text(
                                      FlutterI18n.translate(context,
                                          "bill_form.amount_of_splits_sum_not_total_validation_error"),
                                      style: TextStyle(
                                          color: Color(0xFFe53935),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )
                                : SizedBox(height: 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!createNewBillMode)
                  Container(
                    padding: EdgeInsets.all(8),
                    child: MaterialButton(
                        minWidth: double.infinity,
                        textColor: Colors.red,
                        child: Text(
                            FlutterI18n.translate(
                                context, "bill_form.delete_bill_tooltip"),
                            style: TextStyle(fontWeight: FontWeight.w400)),
                        onPressed: _openDeleteBillDialog),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool sumOfActiveSplitsEqualsAmount() {
    double sum = 0;
    splitUsers.forEach((key, value) {
      if (value) {
        sum += _normalizeDouble(splitPaidControllers[key].text);
      }
    });
    if (_amount == "") {
      return true;
    }
    return sum == _normalizeDouble(_amount);
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
    billDateController.text = dateFormatter.format(_selectedDate);
  }

  Future _selectCategory(BuildContext context) async {
    await showDialog(
        context: context,
        child: Consumer<AppState>(builder: (context, appState, child) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
            title: Text("Select Category"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appState.getAvailableBillCategories().length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    contentPadding: EdgeInsets.only(left: 24),
                    title: Text(appState.getAvailableBillCategories()[index].name),
                    leading: Icon(appState.getAvailableBillCategories()[index].icon),
                    onTap: () => {
                      setState(() {
                        _category = appState.getAvailableBillCategories()[index].name;
                      }),
                      navService.goBack(),
                      billCategoryController.text = appState.getAvailableBillCategories()[index].name
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel",
                    style: TextStyle(fontWeight: FontWeight.w400)),
                onPressed: () {
                  navService.goBack();
                },
              ),
            ],
          );
        }));
  }

  double _normalizeDouble(String _doubleString) {
    return double.parse(_doubleString.replaceAll(",", "."));
  }

  void _createBill() async {
    Bill bill = new Bill();
    bill.description = _description;
    bill.category = _category;
    bill.totalAmount = _normalizeDouble(_amount);
    bill.billingDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate);
    bill.parts = 0;

    List<Split> splits = [];
    for (User user in Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()
        .users) {
      if (splitUsers[user.id]) {
        // create splits for users only if they are involved in the bill
        bill.parts += _normalizeDouble(splitPartsControllers[user.id].text);
        Split split = new Split();
        split.debtor = user.id;
        split.paid = _normalizeDouble(splitPaidControllers[user.id].text);
        split.partsOfBill =
            _normalizeDouble(splitPartsControllers[user.id].text);
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
        PartidoToast.showToast(
            msg:
                FlutterI18n.translate(context, "bill_form.toast_bill_created"));
      }
    } catch (e) {
      logger.e("Failed to save bill", e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "bill_form.toast_failed_to_save_bill"));
    }
  }

  void _updateBill() async {
    Bill updatedBill = new Bill();
    updatedBill.description = _description;
    updatedBill.category = _category;
    updatedBill.totalAmount = _normalizeDouble(_amount);
    updatedBill.billingDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate);
    updatedBill.parts = 0;

    List<Split> splits = [];
    for (User user in Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()
        .users) {
      if (splitUsers[user.id]) {
        // create splits for users only if they are involved in the bill
        updatedBill.parts +=
            _normalizeDouble(splitPartsControllers[user.id].text);
        Split split = new Split();
        split.debtor = user.id;
        split.paid = _normalizeDouble(splitPaidControllers[user.id].text);
        split.partsOfBill =
            _normalizeDouble(splitPartsControllers[user.id].text);
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
        PartidoToast.showToast(
            msg:
                FlutterI18n.translate(context, "bill_form.toast_bill_updated"));
      }
    } catch (e) {
      logger.e("Failed to save bill", e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "bill_form.toast_failed_to_update_bill"));
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
        PartidoToast.showToast(
            msg:
                FlutterI18n.translate(context, "bill_form.toast_bill_deleted"));
      }
    } catch (e) {
      logger.e("Failed to delete bill", e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "bill_form.toast_failed_to_delete_bill"));
    }
  }

  Future _openDeleteBillDialog() async {
    await showDialog(
      context: context,
      child: AlertDialog(
        title: I18nText("bill_form.delete_bill_dialog.title"),
        content: I18nText("bill_form.delete_bill_dialog.question"),
        actions: <Widget>[
          FlatButton(
            child: Text(
                FlutterI18n.translate(
                    context, "bill_form.delete_bill_dialog.answer_no"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: () {
              navService.goBack();
            },
          ),
          FlatButton(
            child: Text(
                FlutterI18n.translate(
                    context, "bill_form.delete_bill_dialog.answer_yes"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: _deleteBill,
          ),
        ],
      ),
    );
  }

  void _splitUserChanged(int userId, bool newValue) => setState(() {
        splitUsers[userId] = newValue;
      });

  _launchFaqUrl(BuildContext context) async {
    String url =
        "https://partido.rocks/faq"; //FlutterI18n.translate(context, "bill_form.split_help.faq_url");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
