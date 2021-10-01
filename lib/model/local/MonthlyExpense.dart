class MonthlyExpense {
  MonthlyExpense(
      this.year,
      this.month,
      this.label,
      this.expense,
      );
  String year;
  String month;
  String label;
  double expense;
  Map entryCategories = {};
}
