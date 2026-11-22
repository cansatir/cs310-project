import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/settings/currency_preferences.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late Future<ExpenseCurrency> _preference = CurrencyPreferences.load();
  bool _saving = false;

  Future<void> _selectCurrency(ExpenseCurrency currency) async {
    final expenses = context.read<ExpenseProvider>();
    if (_saving ||
        expenses.isLoading ||
        expenses.expenses.isNotEmpty ||
        currency == CurrencyPreferences.current.value) {
      return;
    }

    setState(() => _saving = true);
    try {
      await CurrencyPreferences.save(currency);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the currency. Try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final locked = expenses.expenses.isNotEmpty;
    final theme = AppTheme.withTypography(Theme.of(context));

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          children: [
            Text('Currency', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            FutureBuilder<ExpenseCurrency>(
              future: _preference,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return OutlinedButton(
                    onPressed: () => setState(() {
                      _preference = CurrencyPreferences.load();
                    }),
                    child: const Text('Could not load currency. Retry'),
                  );
                }
                if (!snapshot.hasData || expenses.isLoading) {
                  return const LinearProgressIndicator(
                    semanticsLabel: 'Loading currency settings',
                  );
                }
                return ValueListenableBuilder<ExpenseCurrency>(
                  valueListenable: CurrencyPreferences.current,
                  builder: (context, selected, _) => Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final currency in ExpenseCurrency.values)
                        ChoiceChip(
                          label: Text(currency.code),
                          selected: selected == currency,
                          onSelected: locked || _saving
                              ? null
                              : (_) => _selectCurrency(currency),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (locked)
              const Text(
                'Currency is locked while expenses exist so previously entered '
                'amounts keep their original currency.',
              ),
            const SizedBox(height: AppTheme.sectionSpacing),
            Text('About', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Image(
                image: AssetImage('assets/images/spendwise_mark.png'),
                width: 48,
                height: 48,
              ),
              title: Text('SpendWise'),
              subtitle: Text('Track your expenses and see where you spend.'),
            ),
            const SizedBox(height: 12),
            const _AboutImage(),
          ],
        ),
      ),
    );
  }
}

class _AboutImage extends StatelessWidget {
  const _AboutImage();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 64,
      child: Image.network(
        'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png',
        semanticLabel: 'Spending chart illustration',
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading chart illustration',
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image_outlined,
          color: AppTheme.secondaryTextColor(Theme.of(context)),
          semanticLabel: 'Chart illustration unavailable',
        ),
      ),
    );
  }
}
