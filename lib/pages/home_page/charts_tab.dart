import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:partido_client/model/entry.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../app_state.dart';
import '../../linear_icons_icons.dart';

import 'package:intl/intl.dart';

class WeeklyExpense {
  WeeklyExpense(
      this.id,
      this.label,
      this.startDate,
      this.endDate,
      this.expense,
      );
  int id;
  String label;
  DateTime startDate;
  DateTime endDate;
  double expense;
}

class MonthlyExpense {
  MonthlyExpense(this.year, this.month, this.expense);
  String year;
  String month;
  double expense;
  Map entryCategories = {};
}

class ChartsTab {

  static int weekStartDay = 1; // 1=Monday, 7=Sunday

  static Card buildWeeklyGroupStatisticsCard(BuildContext context, AppState appState) {
    DateFormat dateFormatter = new DateFormat(
      FlutterI18n.translate(context, "global.date_format_short"),
    );
    List<WeeklyExpense> weeklyExpenses = [];

    // Sort entries by billingDate first
    // because default is sorted by creationDate
    List<Entry> sortedEntries = List.from(appState.getEntries());
    sortedEntries.sort((a,b) => a.billingDate!.compareTo(b.billingDate!));

    // Calculate earliest date to prepare weeks list
    DateTime earliestDate = DateTime.parse(sortedEntries[0].billingDate!);
    earliestDate = DateTime(earliestDate.year, earliestDate.month, earliestDate.day);
    while (weekStartDay != earliestDate.weekday) {
      earliestDate = earliestDate.subtract(Duration(days: 1));
    }

    // Create weeks list
    DateTime now = DateTime.now();
    DateTime dateToProcess = earliestDate;
    int id = 1;
    while (dateToProcess.isBefore(now)) {
      DateTime startDate = dateToProcess;
      DateTime endDate = dateToProcess.add(
        Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999),
      );
      String label = '${dateFormatter.format(startDate)} - ${dateFormatter.format(endDate)}';

      // Process all entries
      double totalAmount = 0;
      for (Entry entry in sortedEntries) {
        DateTime billingDate = DateTime.parse(entry.billingDate!);
        if (billingDate.isAfter(startDate.subtract(Duration(milliseconds: 1)))
            && billingDate.isBefore(endDate.add(Duration(milliseconds: 1)))) {
          totalAmount += entry.totalAmount!;
        }
      }

      WeeklyExpense weeklyExpense = new WeeklyExpense(id, label, startDate, endDate, totalAmount);
      weeklyExpenses.add(weeklyExpense);
      dateToProcess = dateToProcess.add(Duration(days: 7));
      id++;
    }

    // Cut list to display only last 12 weeks
    if (weeklyExpenses.length > 12) {
      weeklyExpenses = weeklyExpenses.getRange(
          weeklyExpenses.length - 12, weeklyExpenses.length
      ).toList();
    }

    // Save stats from last two weeks in AppState
    appState.setLastWeeklyExpenseStatistics(weeklyExpenses.getRange(
        weeklyExpenses.length - 2, weeklyExpenses.length
    ).toList());

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "charts.weekly_expenses.title"),
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(LinearIcons.calendar_empty, color: Colors.green),
          ),
          Divider(),
          Container(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: 270,
              ),
              primaryYAxis: NumericAxis(
                labelFormat: '{value} '
                    + Provider.of<AppState>(context, listen: false)
                        .getSelectedGroup()!.currency!,
                numberFormat: new NumberFormat(
                  FlutterI18n.translate(context, "global.currency_format"),
                  FlutterI18n.translate(context, "global.locale"),
                ),
              ),
              legend: Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: false),
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.longPress,
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
              ),
              series: <ChartSeries>[
                LineSeries<WeeklyExpense, String>(
                  dataSource: weeklyExpenses,
                  xValueMapper: (WeeklyExpense weeklyExpense, _) => weeklyExpense.label,
                  yValueMapper: (WeeklyExpense weeklyExpense, _) => weeklyExpense.expense,
                  width: 1.5,
                  color: Theme.of(context).accentColor,
                  name: FlutterI18n.translate(context, "charts.weekly_expenses.tooltip"),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    width: 2,
                    height: 2,
                    borderWidth: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Card buildMonthlyGroupStatisticsCard(BuildContext context, AppState appState) {

    List<String> monthlyExpensesMonths = [];
    List<MonthlyExpense> monthlyExpenses = [];

    // Sort entries by billingDate first
    // because default is sorted by creationDate
    List<Entry> sortedEntries = List.from(appState.getEntries());
    sortedEntries.sort((a,b) => a.billingDate!.compareTo(b.billingDate!));

    // Process all entries
    for (Entry entry in sortedEntries) {
      String year = DateTime.parse(entry.billingDate!).year.toString();
      String month = DateTime.parse(entry.billingDate!).month.toString();
      double totalAmount = entry.totalAmount!;
      if (monthlyExpensesMonths.contains(year + month)) {
        monthlyExpenses[monthlyExpensesMonths.indexOf(year + month)].expense += totalAmount;
        if (monthlyExpenses[monthlyExpensesMonths.indexOf(year + month)].entryCategories[entry.category] != null) {
          monthlyExpenses[monthlyExpensesMonths.indexOf(year + month)].entryCategories[entry.category] += totalAmount;
        } else {
          monthlyExpenses[monthlyExpensesMonths.indexOf(year + month)].entryCategories[entry.category] = totalAmount;
        }
      } else {
        monthlyExpensesMonths.add(year + month);
        MonthlyExpense monthlyExpense = new MonthlyExpense(year, month, totalAmount);
        if (monthlyExpense.entryCategories[entry.category] != null) {
          monthlyExpense.entryCategories[entry.category] += totalAmount;
        } else {
          monthlyExpense.entryCategories[entry.category] = totalAmount;
        }
        monthlyExpenses.add(monthlyExpense);
      }
    }

    // Add current month if not already in list
    String currentYear = DateTime.now().year.toString();
    String currentMonth = DateTime.now().month.toString();
    if (!monthlyExpensesMonths.contains(currentYear + currentMonth)) {
      monthlyExpenses.add(new MonthlyExpense(currentYear, currentMonth, 0));
    }

    // Add zeroed months
    List<MonthlyExpense> monthlyExpensesCopy = List.from(monthlyExpenses);
    for (MonthlyExpense monthlyExpense in monthlyExpensesCopy) {
      String year = monthlyExpense.year;
      String month = monthlyExpense.month;
      String nextMonth = (int.parse(month) + 1).toString();
      if (int.parse(nextMonth) > 12) {
        year = (int.parse(year) + 1).toString();
        nextMonth = (1).toString();
      }
      int monthlyExpenseIndex = monthlyExpenses.indexOf(monthlyExpense);
      while (!monthlyExpensesMonths.contains(year + nextMonth)
          && (DateTime(int.parse(year), int.parse(nextMonth)).isBefore(DateTime.now()))
      ) {
        monthlyExpenses.insert(
            monthlyExpenseIndex + 1,
            new MonthlyExpense(year, nextMonth, 0)
        );
        monthlyExpensesMonths.add(year + nextMonth);
        month = (int.parse(month) + 1).toString();
        nextMonth = (int.parse(month) + 1).toString();
        if (int.parse(nextMonth) > 12) {
          year = (int.parse(year) + 1).toString();
          month = (0).toString();
          nextMonth = (1).toString();
        }
        monthlyExpenseIndex++;
      }
    }

    // Cut list to display only last 12 months
    if (monthlyExpenses.length > 12) {
      monthlyExpenses = monthlyExpenses.getRange(
          monthlyExpenses.length - 12, monthlyExpenses.length
      ).toList();
    }

    // Save stats from last two weeks in AppState
    appState.setLastMonthlyExpenseStatistics(monthlyExpenses.getRange(
        monthlyExpenses.length - 2, monthlyExpenses.length
    ).toList());

    // Translate Months
    for (MonthlyExpense monthlyExpense in monthlyExpenses) {
      monthlyExpense.month = FlutterI18n.translate(context, "date.MONTH_" + monthlyExpense.month);
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              FlutterI18n.translate(context, "charts.monthly_expenses.title"),
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(LinearIcons.calendar_31, color: Colors.green),
          ),
          Divider(),
          Container(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelIntersectAction: AxisLabelIntersectAction.wrap,
              ),
              primaryYAxis: NumericAxis(
                labelFormat: '{value} '
                    + Provider.of<AppState>(context, listen: false)
                        .getSelectedGroup()!.currency!,
                numberFormat: new NumberFormat(
                  FlutterI18n.translate(context, "global.currency_format"),
                  FlutterI18n.translate(context, "global.locale"),
                ),
              ),
              legend: Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: false),
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.longPress,
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
              ),
              series: <ChartSeries>[
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['FOOD_GROCERIES'],
                  name: FlutterI18n.translate(context, "entry.categories.FOOD_GROCERIES"),
                  color: Color(0xFF26A69A),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['BARS_RESTAURANTS'],
                  name: FlutterI18n.translate(context, "entry.categories.BARS_RESTAURANTS"),
                  color: Color(0xFF29B6F6),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['SHOPPING'],
                  name: FlutterI18n.translate(context, "entry.categories.SHOPPING"),
                  color: Color(0xFFC0CA33),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['LEISURE_ENTERTAINMENT'],
                  name: FlutterI18n.translate(context, "entry.categories.LEISURE_ENTERTAINMENT"),
                  color: Color(0xFF7986CB),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['FAMILY_FRIENDS'],
                  name: FlutterI18n.translate(context, "entry.categories.FAMILY_FRIENDS"),
                  color: Color(0xFF26C6DA),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['HEALTH_DRUGSTORES'],
                  name: FlutterI18n.translate(context, "entry.categories.HEALTH_DRUGSTORES"),
                  color: Color(0xFF9CCC65),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['HOUSEHOLD_UTILITIES'],
                  name: FlutterI18n.translate(context, "entry.categories.HOUSEHOLD_UTILITIES"),
                  color: Color(0xFF42A5F5),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['MEDIA_ELECTRONICS'],
                  name: FlutterI18n.translate(context, "entry.categories.MEDIA_ELECTRONICS"),
                  color: Color(0xFF7E57C2),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['TRAVEL_VACATION'],
                  name: FlutterI18n.translate(context, "entry.categories.TRAVEL_VACATION"),
                  color: Color(0xFF039BE5),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['SUBSCRIPTIONS_DONATIONS'],
                  name: FlutterI18n.translate(context, "entry.categories.SUBSCRIPTIONS_DONATIONS"),
                  color: Color(0xFFF06292),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['EDUCATION'],
                  name: FlutterI18n.translate(context, "entry.categories.EDUCATION"),
                  color: Color(0xFF00ACC1),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['MISCELLANEOUS'],
                  name: FlutterI18n.translate(context, "entry.categories.MISCELLANEOUS"),
                  color: Color(0xFF80CBC4),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['TAXES_DUTIES'],
                  name: FlutterI18n.translate(context, "entry.categories.MISCELLANEOUS"),
                  color: Color(0xFF7CB342),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['TRANSPORT_CAR'],
                  name: FlutterI18n.translate(context, "entry.categories.TRANSPORT_CAR"),
                  color: Color(0xFFFFB74D),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['INSURANCE_FINANCE'],
                  name: FlutterI18n.translate(context, "entry.categories.INSURANCE_FINANCE"),
                  color: Color(0xFFFF8A65),
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['UNCATEGORIZED'],
                  name: FlutterI18n.translate(context, "entry.categories.UNCATEGORIZED"),
                  color: Color(0xFF9E9E9E),
                ),
                LineSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.month,
                  yValueMapper: (MonthlyExpense expense, _) => expense.expense,
                  opacity: 0,
                  color: Color(0xFFFFFFFF),
                  name: FlutterI18n.translate(context, "charts.monthly_expenses.tooltip"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates number of weeks for a given year as per
  /// https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per
  /// https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int calculateWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy =  ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }
}
