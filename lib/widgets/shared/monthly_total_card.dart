import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/widgets/shared/money_text.dart';
import 'package:flutter/material.dart';

class MonthlyTotalCard extends StatelessWidget {
  const MonthlyTotalCard({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sectionSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly spending', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.smallSpacing),
            MoneyText(total, style: theme.textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
