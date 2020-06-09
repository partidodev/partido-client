import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:partido_client/linear_icons_icons.dart';
import 'package:partido_client/model/bill.dart';
import 'package:retrofit/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _selectedGroupId = -1; // initial value to check if id must be loaded or not

  void initAppState() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    HttpResponse<User> _loginStatusResponse = await api.getLoginStatus();
    if (_loginStatusResponse.response.statusCode == 200) {
      _currentUser = _loginStatusResponse.data;
      _myGroups = await api.getMyGroups();
      notifyListeners();
      // Get current user and his groups first. Then check if user logged
      // in has a preferred group to see and if he can get it's details.
      // (the user may have logged in with an other account, where he cannot
      // see the same groups as before)
      if (_selectedGroupId == -1) {
        int preferredGroupId = preferences.getInt('SELECTEDGROUP');
        for (Group group in _myGroups) {
          if (group.id == preferredGroupId) {
            _selectedGroupId = preferredGroupId;
            reloadReport();
            _selectedGroup = group;
            reloadBillList();
            break;
          }
        }
      }
    }
  }

  void clearAppState() async {
    _selectedGroupId = -1;
    _selectedGroup = new Group(users: []);
    _bills = [];
    _report = new Report(balances: []);
  }

  void refreshAppState() async {
    _selectedGroup = await api.getGroup(_selectedGroupId);
    _bills = await api.getBillsForGroup(_selectedGroupId);
    _report = await api.getReportForGroup(_selectedGroupId);
    _myGroups = await api.getMyGroups();
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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("SELECTEDGROUP", groupId);
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

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
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

  /// 0 = false
  /// 1 = true
  void setRememberLoginStatus(String boolAsNumber) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("REMEMBERLOGIN", boolAsNumber);
  }

  Future<String> getRememberLoginStatus() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("REMEMBERLOGIN");
  }

  List<BillCategory> getAvailableBillCategories() {
    List<BillCategory> availableBillCategories = new List();
    availableBillCategories.add(new BillCategory(1, "Abos & Spenden", LinearIcons.calendar_check));
    availableBillCategories.add(new BillCategory(2, "Bars & Restaurants", LinearIcons.glass_cocktail));
    availableBillCategories.add(new BillCategory(3, "Bildung", LinearIcons.graduation_hat));
    availableBillCategories.add(new BillCategory(4, "Essen & Lebensmittel", LinearIcons.apple));
    availableBillCategories.add(new BillCategory(5, "Familie & Freunde", LinearIcons.users2));
    availableBillCategories.add(new BillCategory(6, "Freizeit & Unterhaltung", LinearIcons.ticket));
    availableBillCategories.add(new BillCategory(7, "Gesundheit & Drogerien", LinearIcons.heart_pulse));
    availableBillCategories.add(new BillCategory(8, "Haushalt & Nebenkosten", LinearIcons.couch));
    availableBillCategories.add(new BillCategory(9, "Medien & Elektronik", LinearIcons.laptop));
    availableBillCategories.add(new BillCategory(10, "Reisen & Urlaub", LinearIcons.earth));
    availableBillCategories.add(new BillCategory(11, "Shopping", LinearIcons.bag));
    availableBillCategories.add(new BillCategory(12, "Sonstiges", LinearIcons.leaf));
    availableBillCategories.add(new BillCategory(13, "Steuern & Abgaben", LinearIcons.calculator2));
    availableBillCategories.add(new BillCategory(14, "Transport & Auto", LinearIcons.bus2));
    availableBillCategories.add(new BillCategory(15, "Versicherungen & Finanzen", LinearIcons.apartment));
    return availableBillCategories;
  }
}

class BillCategory {
  int id;
  String name;
  IconData icon;
  BillCategory(this.id, this.name, this.icon);
}
