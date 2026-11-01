import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Expenses extends StatelessWidget {
  const Expenses({super.key});

  // expense == null -> add a new one, otherwise edit that expense
  void _openExpenseSheet(BuildContext context, {Expense? expense}) {
    final provider = context.read<ExpenseProvider>();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        expense: expense,
        onSave: (saved) {
          if (expense == null) {
            provider.addExpense(saved);
          } else {
            provider.updateExpense(saved);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: () => _openExpenseSheet(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          const Text('The Graph'),
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Text('No expenses yet. Tap + to add one.'),
                  )
                : ExpensesList(
                    expenses: expenses,
                    onRemoveExpense: (expense) =>
                        context.read<ExpenseProvider>().removeExpense(expense),
                    onEditExpense: (expense) =>
                        _openExpenseSheet(context, expense: expense),
                  ),
          ),
        ],
      ),
    );
  }
}
