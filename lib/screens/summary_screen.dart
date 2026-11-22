import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/utils/monthly_summary.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  final _money = NumberFormat.currency(locale: 'en_US', symbol: r'$');

  void _moveMonth(int offset) {
    setState(() => _month = DateTime(_month.year, _month.month + offset));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final summary = MonthlySummary(provider.expenses, _month);
    final maxCategory = summary.categoryTotals.values.fold<double>(
      0, (max, value) => value > max ? value : max,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () => _moveMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM().format(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () => _moveMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly spending', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(_money.format(summary.total), style: theme.textTheme.headlineMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Spending by category', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (summary.total == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No expenses recorded for this month.'),
              ),
            for (final category in Category.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(categoryIcons[category], size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(category.name)),
                        Text(_money.format(summary.categoryTotals[category]!)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: maxCategory == 0
                          ? 0
                          : summary.categoryTotals[category]! / maxCategory,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
