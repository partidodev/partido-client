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
  List<Group> _myGroups = [];
  List<Bill> _bills = [];
  Report _report = new Report(balances: []);
  int _selectedGroupId = -1;

  void initAppState() async {
    _currentUser = await api.getCurrentUser();
    // TODO: remove fix group selection and get this number from SharedPrefs; must be loaded before the following
    if (_selectedGroupId == -1) {
      _selectedGroupId = 1;
    }
    reloadReport();
    reloadSelectedGroup();
    reloadBillList();
    reloadMyGroups();
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
    reloadSelectedGroup();
    reloadBillList();
    reloadReport();
  }

  void reloadSelectedGroup() async {
    _selectedGroup = await api.getGroup(_selectedGroupId);
    notifyListeners();
  }

  void reloadBillList() async {
    _bills = await api.getBillsForGroup(_selectedGroupId);
    notifyListeners();
  }

  void reloadReport() async {
    _report = await api.getReportForGroup(_selectedGroupId);
    notifyListeners();
  }

  void reloadMyGroups() async {
    _myGroups = await api.getMyGroups();
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

  List<Group> getMyGroups() {
    return _myGroups;
  }

  User getUserFromGroupById(int creatorId) {
    for (User user in _selectedGroup.users) {
      if (user.id == creatorId) {
        return user;
      }
    }
  }
}
