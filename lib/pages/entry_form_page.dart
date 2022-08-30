import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:partido_client/model/remote/entry.dart';
import 'package:partido_client/model/remote/split.dart';
import 'package:partido_client/model/remote/user.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:provider/provider.dart';
import 'package:retrofit/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../api/api_service.dart';
import '../app_state.dart';
import '../linear_icons_icons.dart';
import '../navigation_service.dart';
import 'entry_details_page.dart';

class EntryFormPage extends StatefulWidget {
  final Entry? entry;

  EntryFormPage({Key? key, @required this.entry}) : super(key: key);

  @override
  _EntryFormPageState createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  var logger = Logger(printer: PrettyPrinter());

  Api api = ApiService.getApi();

  late NumberFormat currencyFormatter;
  late NumberFormat partFormatter;
  late DateFormat dateFormatter;

  final _formKey = GlobalKey<FormState>();
  bool createNewEntryMode = true;
  bool initDone = false;
  bool formSaved = false;

  String? _category;
  static String defaultCategory = "UNCATEGORIZED";
  String? _description;
  String? _amount;
  DateTime? _selectedDate;

  TextEditingController entryDescriptionController = new TextEditingController();
  TextEditingController entryAmountController = new TextEditingController();
  TextEditingController entryDateController = new TextEditingController();
  TextEditingController entryCategoryController = new TextEditingController();

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

    if (widget.entry == null) {
      _category = defaultCategory;
      // create new entry
      Provider.of<AppState>(context, listen: false)
          .getSelectedGroup()!
          .users
          .forEach((user) {
        splitUsers.putIfAbsent(user.id!, () => true);
        var splitPaidController =
            new TextEditingController(text: currencyFormatter.format(0.00));
        splitPaidControllers.putIfAbsent(user.id!, () => splitPaidController);
        var splitPartsController = new TextEditingController(text: "1");
        splitPartsControllers.putIfAbsent(user.id!, () => splitPartsController);
      });
      if (_selectedDate == null) {
        _selectedDate = DateTime.now();
      }
    } else {
      // edit existing entry
      createNewEntryMode = false;
      entryDescriptionController.text = widget.entry!.description!;
      if (widget.entry!.category != null) {
        _category = widget.entry!.category;
      } else {
        _category = defaultCategory;
      }
      entryAmountController.text =
          currencyFormatter.format(widget.entry!.totalAmount);
      if (_selectedDate == null) {
        _selectedDate = DateTime.parse(widget.entry!.billingDate!);
      }

      Provider.of<AppState>(context, listen: false)
          .getSelectedGroup()!
          .users
          .forEach((user) {
        bool splitFound = false;
        for (Split split in widget.entry!.splits!) {
          if (split.debtor == user.id) {
            splitFound = true;
            splitUsers.putIfAbsent(user.id!, () => true);
            var splitPartsController = new TextEditingController(
                text: partFormatter.format(split.partsOfBill));
            splitPartsControllers.putIfAbsent(
                user.id!, () => splitPartsController);
            var splitPaidController = new TextEditingController(
                text: currencyFormatter.format(split.paid));
            splitPaidControllers.putIfAbsent(
                user.id!, () => splitPaidController);
            break;
          }
        }
        // if no split exists for an user, create defaults with zero-values
        if (!splitFound) {
          splitUsers.putIfAbsent(user.id!, () => false);
          var splitPartsController = new TextEditingController(text: "0");
          splitPartsControllers.putIfAbsent(
              user.id!, () => splitPartsController);
          var splitPaidController =
              new TextEditingController(text: currencyFormatter.format(0.00));
          splitPaidControllers.putIfAbsent(user.id!, () => splitPaidController);
        }
      });
    }
    entryDateController.text = dateFormatter.format(_selectedDate!);
    entryCategoryController.text = FlutterI18n.translate(context, 'entry.categories.' + _category!);
    initDone = true;
  }

  @override
  Widget build(BuildContext context) {
    init(context);
    List<Widget> splitEditingRows = List.empty(growable: true);
    Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()!
        .users
        .forEach((user) {
      splitEditingRows.add(Row(
        children: <Widget>[
          Flexible(
            child: CheckboxListTile(
              title: Text(user.username!),
              onChanged: (newValue) {
                _splitUserChanged(user.id!, newValue!);
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
                  labelText: FlutterI18n.translate(context, "entry_form.parts")),
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
                      .getSelectedGroup()!
                      .currency,
                  labelText: FlutterI18n.translate(context, "entry_form.paid")),
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
        title: (createNewEntryMode)
            ? I18nText('entry_form.create_entry_title')
            : I18nText('entry_form.edit_entry_title'),
        actions: (createNewEntryMode)
            ? <Widget>[
                IconButton(
                    icon: Icon(LinearIcons.check),
                    tooltip: FlutterI18n.translate(
                        context, "entry_form.create_entry_button"),
                    onPressed: () {
                      // save the fields..
                      final form = _formKey.currentState;
                      form!.save();
                      setState(() => formSaved = true);
                      if (form.validate() && sumOfActiveSplitsEqualsAmount()) {
                        _createEntry();
                      }
                    })
              ] : <Widget>[
                IconButton(
                    icon: Icon(LinearIcons.check),
                    tooltip: FlutterI18n.translate(
                        context, "entry_form.update_entry_button"),
                    onPressed: () {
                      // save the fields..
                      final form = _formKey.currentState;
                      form!.save();
                      setState(() => formSaved = true);
                      if (form.validate() && sumOfActiveSplitsEqualsAmount()) {
                        _updateEntry();
                      }
                    })
              ],
      ),
      body: ListView(
        padding: EdgeInsets.all(4),
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
                          FlutterI18n.translate(context, "entry_form.details_title"),
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
                                      context, "entry_form.description")),
                              controller: entryDescriptionController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return FlutterI18n.translate(context,
                                      "entry_form.description_empty_validation_error");
                                }
                                if (value.length > 255) {
                                  return FlutterI18n.translate(context,
                                      "entry_form.description_too_long_validation_error");
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              decoration: InputDecoration(
                                  prefixIcon: Icon(LinearIcons.tag),
                                  suffixIcon: Icon(LinearIcons.chevron_down, size: 20,),
                                  labelText: FlutterI18n.translate(context, "entry_form.category")),
                              controller: entryCategoryController,
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
                                      if (createNewEntryMode) {
                                        splitPaidControllers[Provider.of<AppState>(
                                            context,
                                            listen: false)
                                            .getCurrentUser()!
                                            .id]!
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
                                          context, "entry_form.amount"),
                                      suffixText: Provider.of<AppState>(context,
                                          listen: false)
                                          .getSelectedGroup()!
                                          .currency,
                                      errorMaxLines: 2,
                                    ),
                                    textAlign: TextAlign.right,
                                    controller: entryAmountController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return FlutterI18n.translate(context,
                                            "entry_form.amount_empty_validation_error");
                                      }
                                      if (_normalizeDouble(value) <= 0) {
                                        return FlutterI18n.translate(context,
                                            "entry_form.amount_not_positive_validation_error");
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
                                            context, "entry_form.date")),
                                    controller: entryDateController,
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
                          FlutterI18n.translate(context, "entry_details.splits"),
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            LinearIcons.bubble_question,
                            size: 20,
                          ),
                          tooltip: FlutterI18n.translate(context, "entry_form.split_faq_tooltip"),
                          onPressed: () {
                            _launchFaqUrl(context);
                          },
                        ),
                      ),
                      Divider(),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: splitEditingRows,
                            ),
                            (formSaved && !sumOfActiveSplitsEqualsAmount())
                                ? Padding(
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      FlutterI18n.translate(context,
                                          "entry_form.amount_of_splits_sum_not_total_validation_error"),
                                      style: TextStyle(
                                          color: MediaQuery.of(context).platformBrightness == Brightness.light
                                              ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                                              : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme
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
                !createNewEntryMode ? Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          FlutterI18n.translate(context, "entry_form.delete_entry_tooltip"),
                          style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.light
                              ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                              : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme),
                        )),
                        trailing: Icon(
                          LinearIcons.chevron_right,
                          color: MediaQuery.of(context).platformBrightness == Brightness.light
                              ? Color.fromRGBO(235, 64, 52, 1) // Color for light theme
                              : Color.fromRGBO(255, 99, 71, 1), // Color for dark theme,
                        ),
                        onTap: _openDeleteEntryDialog,
                      ),
                    ],
                  ),
                ) : Container(),
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
        sum += _normalizeDouble(splitPaidControllers[key]!.text);
      }
    });
    if (_amount == "") {
      return true;
    }
    return sum == _normalizeDouble(_amount!);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate!,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2100, 12));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    entryDateController.text = dateFormatter.format(_selectedDate!);
  }

  Future _selectCategory(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (_) => Consumer<AppState>(builder: (context, appState, child) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
            title: I18nText('entry_form.select_category_dialog.title'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appState.getAvailableEntryCategories()!.length,
                itemBuilder: (BuildContext context, int index) {
                  String key = appState.getAvailableEntryCategories()!.keys.elementAt(index);
                  return ListTile(
                    contentPadding: EdgeInsets.only(left: 24),
                    title: I18nText('entry.categories.' + key),
                    leading: Icon(appState.getAvailableEntryCategories()![key]),
                    onTap: () => {
                      setState(() {
                        _category = key;
                      }),
                      navService.goBack(),
                      entryCategoryController.text = FlutterI18n.translate(context, 'entry.categories.' + key)
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(FlutterI18n.translate(context, "global.cancel"),
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
    _doubleString = _doubleString.replaceAll(",", ".");
    while (_doubleString.indexOf(".") != _doubleString.lastIndexOf(".")) {
      _doubleString = _doubleString.replaceFirst(".", "");
    }
    return double.parse(_doubleString);
  }

  void _createEntry() async {
    Entry entry = new Entry(parts: 0);
    entry.description = _description!;
    entry.category = _category!;
    entry.totalAmount = _normalizeDouble(_amount!);
    entry.billingDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate!);

    List<Split> splits = [];
    for (User user in Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()!
        .users) {
      if (splitUsers[user.id]!) {
        // create splits for users only if they are involved in the entry
        entry.parts += _normalizeDouble(splitPartsControllers[user.id]!.text);
        Split split = new Split();
        split.debtor = user.id;
        split.paid = _normalizeDouble(splitPaidControllers[user.id]!.text);
        split.partsOfBill = _normalizeDouble(splitPartsControllers[user.id]!.text);
        splits.add(split);
      }
    }
    entry.splits = splits;

    try {
      HttpResponse<Entry> response = await api.createEntry(entry,
          Provider.of<AppState>(context, listen: false).getSelectedGroupId());
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack();
        PartidoToast.showToast(
            msg:
                FlutterI18n.translate(context, "entry_form.toast_entry_created"));
      }
    } catch (e) {
      logger.e("Failed to save entry", e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "entry_form.toast_failed_to_save_entry"));
    }
  }

  void _updateEntry() async {
    Entry updatedEntry = new Entry(parts: 0);
    updatedEntry.description = _description!;
    updatedEntry.category = _category!;
    updatedEntry.totalAmount = _normalizeDouble(_amount!);
    updatedEntry.billingDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(_selectedDate!);

    List<Split> splits = [];
    for (User user in Provider.of<AppState>(context, listen: false)
        .getSelectedGroup()!
        .users) {
      if (splitUsers[user.id]!) {
        // create splits for users only if they are involved in the entry
        updatedEntry.parts +=
            _normalizeDouble(splitPartsControllers[user.id]!.text);
        Split split = new Split();
        split.debtor = user.id;
        split.paid = _normalizeDouble(splitPaidControllers[user.id]!.text);
        split.partsOfBill =
            _normalizeDouble(splitPartsControllers[user.id]!.text);
        splits.add(split);
      }
    }
    updatedEntry.splits = splits;

    try {
      HttpResponse<Entry> response = await api.updateEntry(
          updatedEntry,
          Provider.of<AppState>(context, listen: false).getSelectedGroupId(),
          widget.entry!.id!);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack(); // close entry editing screen
        navService.goBack(); // close outdated entry details screen
        navService.push(MaterialPageRoute(
            builder: (context) => EntryDetailsPage(entry: response.data)));
        PartidoToast.showToast(
            msg:
                FlutterI18n.translate(context, "entry_form.toast_entry_updated"));
      }
    } catch (e) {
      logger.e("Failed to save entry", e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "entry_form.toast_failed_to_update_entry"));
    }
  }

  void _deleteEntry() async {
    try {
      HttpResponse<String> response = await api.deleteEntry(widget.entry!.id!);
      if (response.response.statusCode == 200) {
        Provider.of<AppState>(context, listen: false).refreshAppState();
        navService.goBack(); // close entry deleting dialog
        navService.goBack(); // close entry editing screen
        navService.goBack(); // close entry details screen
        PartidoToast.showToast(
            msg:
                FlutterI18n.translate(context, "entry_form.toast_entry_deleted"));
      }
    } catch (e) {
      logger.e("Failed to delete entry", e);
      PartidoToast.showToast(
          msg: FlutterI18n.translate(
              context, "entry_form.toast_failed_to_delete_entry"));
    }
  }

  Future _openDeleteEntryDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: I18nText("entry_form.delete_entry_dialog.title"),
        content: I18nText("entry_form.delete_entry_dialog.question"),
        actions: <Widget>[
          TextButton(
            child: Text(
                FlutterI18n.translate(
                    context, "entry_form.delete_entry_dialog.answer_no"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: () {
              navService.goBack();
            },
          ),
          TextButton(
            child: Text(
                FlutterI18n.translate(
                    context, "entry_form.delete_entry_dialog.answer_yes"),
                style: TextStyle(fontWeight: FontWeight.w400)),
            onPressed: _deleteEntry,
          ),
        ],
      ),
    );
  }

  void _splitUserChanged(int userId, bool newValue) => setState(() {
        splitUsers[userId] = newValue;
      });

  _launchFaqUrl(BuildContext context) async {
    String url =  FlutterI18n.translate(context, "entry_form.split_faq_link");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
