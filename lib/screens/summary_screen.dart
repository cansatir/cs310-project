import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/utils/monthly_summary.dart';
import 'package:expense_tracker/widgets/shared/money_text.dart';
import 'package:expense_tracker/widgets/shared/month_selector.dart';
import 'package:expense_tracker/widgets/shared/monthly_total_card.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final summary = MonthlySummary(provider.expenses, _month);
    final maxCategory = summary.categoryTotals.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppTheme.pagePadding),
                children: [
                  MonthSelector(
                    month: _month,
                    onChanged: (month) => setState(() => _month = month),
                  ),
                  const SizedBox(height: AppTheme.pagePadding),
                  MonthlyTotalCard(total: summary.total),
                  const SizedBox(height: AppTheme.sectionSpacing),
                  Text(
                    'Spending by category',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.mediumSpacing),
                  if (summary.total == 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.mediumSpacing,
                      ),
                      child: Text('No expenses recorded for this month.'),
                    ),
                  for (final category in Category.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.smallSpacing,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppTheme.smallSpacing,
                            runSpacing: AppTheme.smallSpacing,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(categoryIcons[category], size: 20),
                              Text(category.name),
                              MoneyText(summary.categoryTotals[category]!),
                            ],
                          ),
                          if (maxCategory > 0) ...[
                            const SizedBox(height: AppTheme.smallSpacing),
                            LinearProgressIndicator(
                              value:
                                  summary.categoryTotals[category]! /
                                  maxCategory,
                              semanticsLabel:
                                  '${category.name} share of the largest category',
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
