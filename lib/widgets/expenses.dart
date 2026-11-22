import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/utils/monthly_summary.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/shared/month_selector.dart';
import 'package:expense_tracker/widgets/shared/monthly_total_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _openExpenseSheet({Expense? expense}) {
    final provider = context.read<ExpenseProvider>();
    showModalBottomSheet<void>(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (_) => NewExpense(
        expense: expense,
        onSave: (saved) {
          if (expense == null) {
            provider.addExpense(saved);
            // A newly added record should be visible when the form closes.
            setState(
              () => _month = DateTime(saved.date.year, saved.date.month),
            );
          } else {
            provider.updateExpense(saved);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final summary = MonthlySummary(provider.expenses, _month);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SpendWise')),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading expenses',
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppTheme.pagePadding),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MonthSelector(
                            month: _month,
                            onChanged: (month) =>
                                setState(() => _month = month),
                          ),
                          const SizedBox(height: AppTheme.smallSpacing),
                          MonthlyTotalCard(total: summary.total),
                          const SizedBox(height: AppTheme.pagePadding),
                          FilledButton.icon(
                            onPressed: () => _openExpenseSheet(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add expense'),
                          ),
                          const SizedBox(height: AppTheme.sectionSpacing),
                          Text(
                            'Recent expenses',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppTheme.smallSpacing),
                          if (summary.expenses.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                provider.expenses.isEmpty
                                    ? 'No expenses yet. Add your first expense.'
                                    : 'No expenses this month.',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.pagePadding,
                    ),
                    sliver: ExpensesList(
                      asSliver: true,
                      expenses: summary.expenses,
                      onRemoveExpense: provider.removeExpense,
                      onEditExpense: (expense) =>
                          _openExpenseSheet(expense: expense),
                    ),
                  ),
                  if (summary.largestCategory != null)
                    SliverPadding(
                      padding: const EdgeInsets.all(AppTheme.pagePadding),
                      sliver: SliverToBoxAdapter(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.pagePadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Insight',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppTheme.smallSpacing),
                                Text(
                                  '${summary.largestCategory!.name} is the largest category this month.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
