import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/settings/currency_preferences.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    required this.onEditExpense,
    this.asSliver = false,
  });

  final List<Expense> expenses;
  final ValueChanged<Expense> onRemoveExpense;
  final ValueChanged<Expense> onEditExpense;
  final bool asSliver;

  Future<bool> _confirmRemoval(BuildContext context, Expense expense) async {
    final amount = CurrencyPreferences.current.value.format(expense.amount);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete expense?'),
            content: Text('Delete "${expense.title}" for $amount?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildItem(BuildContext context, int index) {
    // Capture the record, not a potentially stale index after an async dialog.
    final expense = expenses[index];
    final colors = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(expense.id),
      background: Container(
        color: colors.secondaryContainer,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Icon(Icons.edit, color: colors.onSecondaryContainer),
      ),
      secondaryBackground: Container(
        color: colors.errorContainer,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Icon(Icons.delete, color: colors.onErrorContainer),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEditExpense(expense);
          return false;
        }
        return _confirmRemoval(context, expense);
      },
      onDismissed: (_) => onRemoveExpense(expense),
      child: ExpenseItem(
        expense,
        onEdit: () => onEditExpense(expense),
        onDelete: () async {
          if (await _confirmRemoval(context, expense) && context.mounted) {
            onRemoveExpense(expense);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => asSliver
      ? SliverList.builder(itemCount: expenses.length, itemBuilder: _buildItem)
      : ListView.builder(itemCount: expenses.length, itemBuilder: _buildItem);
}
