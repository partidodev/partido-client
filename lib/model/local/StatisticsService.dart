import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:partido_client/model/local/MonthlyExpense.dart';
import 'package:partido_client/model/local/WeeklyExpense.dart';
import 'package:partido_client/model/remote/entry.dart';

class StatisticsService {

  static int weekStartDay = 1; // 1=Monday, 7=Sunday

  static List<WeeklyExpense> calculateWeeklyExpenses(List<Entry> entries) {
    List<WeeklyExpense> weeklyExpenses = [];

    if (entries.length == 0) {
      return weeklyExpenses;
    }

    // Sort entries by billingDate first
    // because default is sorted by creationDate
    List<Entry> sortedEntries = List.from(entries);
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
      String label = '';

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

    return weeklyExpenses;
  }

  static List<MonthlyExpense> calculateMonthlyExpenses(List<Entry> entries) {
    List<String> monthlyExpensesMonths = [];
    List<MonthlyExpense> monthlyExpenses = [];

    // Sort entries by billingDate first
    // because default is sorted by creationDate
    List<Entry> sortedEntries = List.from(entries);
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
        MonthlyExpense monthlyExpense = new MonthlyExpense(year, month, '', totalAmount);
        if (monthlyExpense.entryCategories[entry.category] != null) {
          monthlyExpense.entryCategories[entry.category] += totalAmount;
        } else {
          monthlyExpense.entryCategories[entry.category] = totalAmount;
        }
        monthlyExpenses.add(monthlyExpense);
      }
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
            new MonthlyExpense(year, nextMonth, '', 0)
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
    return monthlyExpenses;
  }

  static List<WeeklyExpense> applyTranslationsToWeeklyExpenseStatistics(BuildContext context, List<WeeklyExpense> weeklyExpenses) {
    DateFormat dateFormatter = new DateFormat(FlutterI18n.translate(context, "global.date_format_short"));
    for (WeeklyExpense weeklyExpense in weeklyExpenses) {
      String label = '${dateFormatter.format(weeklyExpense.startDate)} - ${dateFormatter.format(weeklyExpense.endDate)}';
      weeklyExpense.label = label;
    }
    return weeklyExpenses;
  }

  static List<MonthlyExpense> applyTranslationsToMonthlyExpenseStatistics(BuildContext context, List<MonthlyExpense> monthlyExpenses) {
    for (MonthlyExpense monthlyExpense in monthlyExpenses) {
      monthlyExpense.label = FlutterI18n.translate(context, "date.MONTH_" + monthlyExpense.month);
    }
    return monthlyExpenses;
  }
}
