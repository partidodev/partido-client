import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:partido_client/model/local/MonthlyExpense.dart';
import 'package:partido_client/model/local/StatisticsService.dart';
import 'package:partido_client/model/local/WeeklyExpense.dart';
import 'package:partido_client/widgets/partido_toast.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../app_state.dart';
import '../../linear_icons_icons.dart';

import 'package:intl/intl.dart';

class ChartsTab {

  static Card buildWeeklyGroupStatisticsCard(BuildContext context, AppState appState) {
    List<WeeklyExpense> weeklyExpenses = appState.getWeeklyExpenseStatistics();
    weeklyExpenses = StatisticsService.applyTranslationsToWeeklyExpenseStatistics(context, weeklyExpenses);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.only(left: 16, right: 0),
            title: Text(
              FlutterI18n.translate(context, "charts.weekly_expenses.title"),
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(LinearIcons.calendar_empty, color: Colors.green),
            trailing: IconButton(
              icon: Icon(
                LinearIcons.bubble_question,
                size: 20,
              ),
              onPressed: () {
                PartidoToast.showToast(
                    msg: FlutterI18n.translate(context, "charts.tips.long_press_description"));
              },
            ),
          ),
          Divider(),
          Container(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(labelRotation: 270),
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
              tooltipBehavior: TooltipBehavior(enable: true),
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
                  animationDuration: 750,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Card buildMonthlyGroupStatisticsCard(BuildContext context, AppState appState) {
    List<MonthlyExpense> monthlyExpenses = appState.getMonthlyExpenseStatistics();
    monthlyExpenses = StatisticsService.applyTranslationsToMonthlyExpenseStatistics(context, monthlyExpenses);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.only(left: 16, right: 0),
            title: Text(
              FlutterI18n.translate(context, "charts.monthly_expenses.title"),
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(LinearIcons.calendar_31, color: Colors.green),
            trailing: IconButton(
              icon: Icon(
                LinearIcons.bubble_question,
                size: 20,
              ),
              onPressed: () {
                PartidoToast.showToast(
                    msg: FlutterI18n.translate(context, "charts.tips.long_press_description"));
              },
            ),
          ),
          Divider(),
          Container(
            height: 275,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(labelRotation: 270),
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
              tooltipBehavior: TooltipBehavior(enable: true),
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.longPress,
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
              ),
              series: <ChartSeries>[
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['FOOD_GROCERIES'],
                  name: FlutterI18n.translate(context, "entry.categories.FOOD_GROCERIES"),
                  color: Color(0xFF26A69A),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['BARS_RESTAURANTS'],
                  name: FlutterI18n.translate(context, "entry.categories.BARS_RESTAURANTS"),
                  color: Color(0xFF29B6F6),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['SHOPPING'],
                  name: FlutterI18n.translate(context, "entry.categories.SHOPPING"),
                  color: Color(0xFFC0CA33),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['LEISURE_ENTERTAINMENT'],
                  name: FlutterI18n.translate(context, "entry.categories.LEISURE_ENTERTAINMENT"),
                  color: Color(0xFF7986CB),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['FAMILY_FRIENDS'],
                  name: FlutterI18n.translate(context, "entry.categories.FAMILY_FRIENDS"),
                  color: Color(0xFF26C6DA),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['HEALTH_DRUGSTORES'],
                  name: FlutterI18n.translate(context, "entry.categories.HEALTH_DRUGSTORES"),
                  color: Color(0xFF9CCC65),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['HOUSEHOLD_UTILITIES'],
                  name: FlutterI18n.translate(context, "entry.categories.HOUSEHOLD_UTILITIES"),
                  color: Color(0xFF42A5F5),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['MEDIA_ELECTRONICS'],
                  name: FlutterI18n.translate(context, "entry.categories.MEDIA_ELECTRONICS"),
                  color: Color(0xFF7E57C2),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['TRAVEL_VACATION'],
                  name: FlutterI18n.translate(context, "entry.categories.TRAVEL_VACATION"),
                  color: Color(0xFF039BE5),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['SUBSCRIPTIONS_DONATIONS'],
                  name: FlutterI18n.translate(context, "entry.categories.SUBSCRIPTIONS_DONATIONS"),
                  color: Color(0xFFF06292),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['EDUCATION'],
                  name: FlutterI18n.translate(context, "entry.categories.EDUCATION"),
                  color: Color(0xFF00ACC1),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['MISCELLANEOUS'],
                  name: FlutterI18n.translate(context, "entry.categories.MISCELLANEOUS"),
                  color: Color(0xFF80CBC4),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['TAXES_DUTIES'],
                  name: FlutterI18n.translate(context, "entry.categories.MISCELLANEOUS"),
                  color: Color(0xFF7CB342),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['TRANSPORT_CAR'],
                  name: FlutterI18n.translate(context, "entry.categories.TRANSPORT_CAR"),
                  color: Color(0xFFFFB74D),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['INSURANCE_FINANCE'],
                  name: FlutterI18n.translate(context, "entry.categories.INSURANCE_FINANCE"),
                  color: Color(0xFFFF8A65),
                  animationDuration: 750,
                ),
                StackedColumnSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.entryCategories['UNCATEGORIZED'],
                  name: FlutterI18n.translate(context, "entry.categories.UNCATEGORIZED"),
                  color: Color(0xFF9E9E9E),
                  animationDuration: 750,
                ),
                LineSeries<MonthlyExpense, String>(
                  dataSource: monthlyExpenses,
                  xValueMapper: (MonthlyExpense expense, _) => expense.label,
                  yValueMapper: (MonthlyExpense expense, _) => expense.expense,
                  opacity: 0,
                  color: Color(0xFFFFFFFF),
                  animationDuration: 750,
                  name: FlutterI18n.translate(context, "charts.monthly_expenses.tooltip"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
