import 'package:flutter/foundation.dart';
import 'package:partido_client/model/bill.dart';

import 'api/api.dart';
import 'api/api_service.dart';
import 'model/user.dart';

class AppState extends ChangeNotifier {

  Api api = ApiService.getApi();

  User _currentUser = null;
  List<Bill> _bills = [];
  int _selectedGroupId = -1;

  void initAppState() {
    changeSelectedGroup(1);
  }

  // Adds [bill] to current group.
  // This is the only way to modify the bill list from the outside.
  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  void replaceBillList(List<Bill> billList) {
    _bills = billList;
    notifyListeners();
  }

  List<Bill> getBills() {
    return _bills;
  }

  void changeSelectedGroup(int groupId) async {
    _selectedGroupId = groupId;
    this._bills = await api.getBillsForGroup(groupId);
    notifyListeners();
  }

  int getSelectedGroup() {
    return _selectedGroupId;
  }
}
