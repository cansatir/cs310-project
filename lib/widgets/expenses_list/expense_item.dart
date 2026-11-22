import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/widgets/shared/money_text.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem(this.expense, {super.key, this.onEdit, this.onDelete});

  final Expense expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    expense.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    tooltip: 'Actions for ${expense.title}',
                    onSelected: (action) {
                      if (action == 'edit') onEdit?.call();
                      if (action == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                  ),
              ],
            ),
            if (expense.note?.isNotEmpty ?? false) ...[
              Text(expense.note!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppTheme.smallSpacing),
            ],
            MoneyText(expense.amount, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.smallSpacing),
            Wrap(
              spacing: AppTheme.mediumSpacing,
              runSpacing: AppTheme.smallSpacing,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(categoryIcons[expense.category], size: 20),
                Text(expense.category.name),
                Text(expense.formattedDate, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
