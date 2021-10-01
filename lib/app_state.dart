import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:partido_client/linear_icons_icons.dart';
import 'package:partido_client/model/local/StatisticsService.dart';
import 'package:partido_client/model/remote/entry.dart';
import 'package:retrofit/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api.dart';
import 'api/api_service.dart';
import 'model/local/MonthlyExpense.dart';
import 'model/local/WeeklyExpense.dart';
import 'model/remote/group.dart';
import 'model/remote/report.dart';
import 'model/remote/user.dart';

class AppState extends ChangeNotifier {
  Api api = ApiService.getApi();

  User? _currentUser;
  Group? _selectedGroup;
  List<Group> _myGroups = [];
  List<Entry> _entries = [];
  Report? _report;
  int _selectedGroupId = -1; // initial value to check if id must be loaded or not
  Map? _availableEntryCategories;
  DateTime now = DateTime.now();
  Map<int, String>? _processedEntryListTitles;
  bool stateInitialized = false;
  List<WeeklyExpense> _weeklyExpenseStatistics = [];
  List<MonthlyExpense> _monthlyExpenseStatistics = [];

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
        int? preferredGroupId = preferences.getInt('SELECTEDGROUP');
        for (Group group in _myGroups) {
          if (group.id == preferredGroupId) {
            _selectedGroupId = preferredGroupId!;
            reloadReport();
            _selectedGroup = group;
            reloadEntryList();
            break;
          }
        }
      }
      stateInitialized = true;
      notifyListeners();
    }
    _availableEntryCategories = loadAvailableEntryCategories();
  }

  void clearAppState() async {
    _selectedGroupId = -1;
    _selectedGroup = null;
    _entries = [];
    _report = null;
  }

  Future<void> refreshAppState() async {
    if (_selectedGroupId != -1) {
      _selectedGroup = await api.getGroup(_selectedGroupId);
      _entries = await api.getEntriesForGroup(_selectedGroupId);
      _processedEntryListTitles = processEntryListTitles(_entries);
      _report = await api.getReportForGroup(_selectedGroupId);
      updateExpenseStatistics();
      _myGroups = await api.getMyGroups();
      notifyListeners();
    }
  }

  void addEntry(Entry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void replaceEntryList(List<Entry> entryList) {
    _entries = entryList;
    notifyListeners();
  }

  List<Entry> getEntries() {
    return _entries;
  }

  Map<int, String>? getProcessedEntryListTitles() {
    return _processedEntryListTitles;
  }

  Report? getReport() {
    return _report;
  }

  void changeSelectedGroup(int groupId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("SELECTEDGROUP", groupId);
    _selectedGroupId = groupId;
    reloadSelectedGroup();
    reloadEntryList();
    reloadReport();
  }

  void reloadSelectedGroup() async {
    _selectedGroup = await api.getGroup(_selectedGroupId);
    notifyListeners();
  }

  void reloadEntryList() async {
    _entries = await api.getEntriesForGroup(_selectedGroupId);
    _processedEntryListTitles = processEntryListTitles(_entries);
    updateExpenseStatistics();
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

  Group? getSelectedGroup() {
    return _selectedGroup;
  }

  User? getCurrentUser() {
    return _currentUser;
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  List<Group> getMyGroups() {
    return _myGroups;
  }

  User? getUserFromGroupById(int creatorId) {
    for (User user in _selectedGroup!.users) {
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

  Future<String?> getRememberLoginStatus() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("REMEMBERLOGIN");
  }

  Map loadAvailableEntryCategories() {
    Map entryCategories = new Map();
    entryCategories["SUBSCRIPTIONS_DONATIONS"] = LinearIcons.calendar_check;
    entryCategories["BARS_RESTAURANTS"] = LinearIcons.glass2;
    entryCategories["EDUCATION"] = LinearIcons.graduation_hat;
    entryCategories["FOOD_GROCERIES"] = LinearIcons.bread;
    entryCategories["FAMILY_FRIENDS"] = LinearIcons.group_work;
    entryCategories["LEISURE_ENTERTAINMENT"] = LinearIcons.ticket;
    entryCategories["HEALTH_DRUGSTORES"] = LinearIcons.heart_pulse;
    entryCategories["HOUSEHOLD_UTILITIES"] = LinearIcons.couch;
    entryCategories["MEDIA_ELECTRONICS"] = LinearIcons.laptop;
    entryCategories["TRAVEL_VACATION"] = LinearIcons.earth;
    entryCategories["SHOPPING"] = LinearIcons.bag;
    entryCategories["MISCELLANEOUS"] = LinearIcons.leaf;
    entryCategories["TAXES_DUTIES"] = LinearIcons.calculator2;
    entryCategories["TRANSPORT_CAR"] = LinearIcons.bus2;
    entryCategories["UNCATEGORIZED"] = LinearIcons.cart;
    entryCategories["INSURANCE_FINANCE"] = LinearIcons.apartment;
    return entryCategories;
  }

  Map? getAvailableEntryCategories() {
    return _availableEntryCategories;
  }

  Map<int, String> processEntryListTitles(List<Entry> entries) {
    Map<int, String> processEntryListTitles = new Map();
    Map<String, String> titleUsed = new Map();
    for (int i=0; i < entries.length; i++) {
      if (isToday(entries[i])) {
        if (titleUsed['TODAY'] == null) {
          processEntryListTitles[i] = 'TODAY';
          titleUsed['TODAY'] = "true";
        }
      } else if (isYesterday(entries[i])) {
        if (titleUsed['YESTERDAY'] == null) {
          processEntryListTitles[i] = 'YESTERDAY';
          titleUsed['YESTERDAY'] = "true";
        }
      } else if (isThisWeek(entries[i])) {
        if (titleUsed['THIS_WEEK'] == null) {
          processEntryListTitles[i] = 'THIS_WEEK';
          titleUsed['THIS_WEEK'] = "true";
        }
      } else if (isThisMonth(entries[i])) {
        if (titleUsed['THIS_MONTH'] == null) {
          processEntryListTitles[i] = 'THIS_MONTH';
          titleUsed['THIS_MONTH'] = "true";
        }
      } else {
        int month = DateTime.parse(entries[i].creationDate!).month;
        int year = DateTime.parse(entries[i].creationDate!).year;
        if (now.year == year && titleUsed["MONTH_$month"] == null) {
          processEntryListTitles[i] = 'MONTH_$month';
          titleUsed['MONTH_$month'] = "true";
        } else if (now.year != year && titleUsed["MONTH_$month#$year"] == null) {
          processEntryListTitles[i] = 'MONTH_$month#$year';
          titleUsed['MONTH_$month#$year'] = "true";
        }
      }
    }
    return processEntryListTitles;
  }

  bool isToday(Entry entry) {
    if (DateTime.parse(entry.creationDate!).isAfter(startOfToday())
        && DateTime.parse(entry.creationDate!).isBefore(endOfToday())) {
      return true;
    }
    return false;
  }

  bool isYesterday(Entry entry) {
    if (DateTime.parse(entry.creationDate!).isAfter(startOfYesterday()) &&
        DateTime.parse(entry.creationDate!).isBefore(startOfToday())) {
      return true;
    }
    return false;
  }

  bool isThisWeek(Entry entry) {
    if (DateTime.parse(entry.creationDate!).isAfter(startOfThisWeek()) &&
        DateTime.parse(entry.creationDate!).isBefore(startOfYesterday())) {
      return true;
    }
    return false;
  }

  bool isThisMonth(Entry entry) {
    if (DateTime.parse(entry.creationDate!).isAfter(startOfThisMonth()) &&
        DateTime.parse(entry.creationDate!).isBefore(startOfThisWeek())) {
      return true;
    }
    return false;
  }

  DateTime startOfToday() {
    return DateTime(now.year, now.month, now.day);
  }

  DateTime startOfYesterday() {
    return startOfToday().subtract(Duration(days: 1));
  }

  DateTime startOfThisWeek() {
    return startOfToday().subtract(Duration(days: now.weekday - 1));
  }

  DateTime startOfThisMonth() {
    return startOfToday().subtract(Duration(days: now.day - 1));
  }

  DateTime endOfToday() {
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
  }

  void updateExpenseStatistics() {
    _weeklyExpenseStatistics = StatisticsService.calculateWeeklyExpenses(_entries);
    _monthlyExpenseStatistics = StatisticsService.calculateMonthlyExpenses(_entries);
  }

  List<WeeklyExpense> getWeeklyExpenseStatistics() {
    return _weeklyExpenseStatistics;
  }

  void setWeeklyExpenseStatistics(List<WeeklyExpense> list) {
    _weeklyExpenseStatistics = list;
    notifyListeners();
  }

  List<MonthlyExpense> getMonthlyExpenseStatistics() {
    return _monthlyExpenseStatistics;
  }

  void setMonthlyExpenseStatistics(List<MonthlyExpense> list) {
    _monthlyExpenseStatistics = list;
    notifyListeners();
  }
}
