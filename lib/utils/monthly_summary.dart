import 'package:expense_tracker/models/expense.dart';

class MonthlySummary {
  MonthlySummary(Iterable<Expense> expenses, DateTime month) {
    categoryTotals = {for (final category in Category.values) category: 0.0};
    for (final expense in expenses) {
      if (expense.date.year == month.year && expense.date.month == month.month) {
        categoryTotals[expense.category] = categoryTotals[expense.category]! + expense.amount;
        total += expense.amount;
      }
    }
  }

  late final Map<Category, double> categoryTotals;
  double total = 0;
}
