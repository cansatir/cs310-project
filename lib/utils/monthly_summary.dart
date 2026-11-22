import 'package:expense_tracker/models/expense.dart';

class MonthlySummary {
  MonthlySummary(Iterable<Expense> expenses, DateTime month) {
    this.expenses =
        expenses
            .where(
              (expense) =>
                  expense.date.year == month.year &&
                  expense.date.month == month.month,
            )
            .toList()
          ..sort((a, b) {
            final byDate = b.date.compareTo(a.date);
            return byDate == 0 ? a.id.compareTo(b.id) : byDate;
          });
    categoryTotals = {for (final category in Category.values) category: 0.0};
    for (final expense in this.expenses) {
      categoryTotals[expense.category] =
          categoryTotals[expense.category]! + expense.amount;
      total += expense.amount;
    }
  }

  late final List<Expense> expenses;
  late final Map<Category, double> categoryTotals;
  double total = 0;

  Category? get largestCategory {
    Category? result;
    var largest = 0.0;
    for (final entry in categoryTotals.entries) {
      if (entry.value > largest) {
        result = entry.key;
        largest = entry.value;
      }
    }
    return result;
  }
}
