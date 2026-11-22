import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/monthly_summary.dart';

Expense expense(double amount, DateTime date, Category category) => Expense(
  title: 'Test', amount: amount, date: date, category: category,
);

void main() {
  test('filters by month and year and totals categories', () {
    final summary = MonthlySummary([
      expense(480, DateTime(2026, 11, 3), Category.Food),
      expense(300, DateTime(2026, 11, 5), Category.Transport),
      expense(700, DateTime(2026, 11, 10), Category.Shopping),
      expense(1000, DateTime(2026, 11, 15), Category.Entertainment),
      expense(200, DateTime(2025, 11, 3), Category.Food),
      expense(900, DateTime(2026, 10, 3), Category.Food),
    ], DateTime(2026, 11));
    expect(summary.total, 2480);
    expect(summary.categoryTotals[Category.Food], 480);
    expect(summary.categoryTotals[Category.Bills], 0);
    expect(summary.categoryTotals.length, 7);
  });

  test('empty month has zero total and seven zero categories', () {
    final summary = MonthlySummary([], DateTime(2026, 11));
    expect(summary.total, 0);
    expect(summary.categoryTotals.values.every((v) => v == 0), isTrue);
  });
}
