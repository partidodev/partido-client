import 'package:flutter/foundation.dart';
import 'package:partido_client/model/bill.dart';

import 'api/api.dart';
import 'api/api_service.dart';
import 'model/group.dart';
import 'model/report.dart';
import 'model/user.dart';

class AppState extends ChangeNotifier {
  Api api = ApiService.getApi();

  User _currentUser = new User();
  Group _selectedGroup = new Group(users: []);
  List<Bill> _bills = [];
  Report _report = new Report(balances: []);
  int _selectedGroupId = -1;

  void initAppState() async {
    _currentUser = await api.getCurrentUser();
    changeSelectedGroup(1); // TODO: remove fix group selection and get this number from SharedPrefs
  }

  void refreshAppState() async {
    _bills = await api.getBillsForGroup(_selectedGroupId);
    _report = await api.getReportForGroup(_selectedGroupId);
    notifyListeners();
  }

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

  Report getReport() {
    return _report;
  }

  void changeSelectedGroup(int groupId) async {
    _selectedGroupId = groupId;
    _selectedGroup = await api.getGroup(groupId);
    _bills = await api.getBillsForGroup(_selectedGroupId);
    _report = await api.getReportForGroup(_selectedGroupId);
    notifyListeners();
  }

  int getSelectedGroupId() {
    return _selectedGroupId;
  }

  Group getSelectedGroup() {
    return _selectedGroup;
  }

  User getCurrentUser() {
    return _currentUser;
  }

  User getUserFromGroupById(int creatorId) {
    for (User user in _selectedGroup.users) {
      if (user.id == creatorId) {
        return user;
      }
    }
  }
}
