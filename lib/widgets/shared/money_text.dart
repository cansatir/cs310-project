import 'package:expense_tracker/settings/currency_preferences.dart';
import 'package:flutter/material.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style});

  final double amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ExpenseCurrency>(
    valueListenable: CurrencyPreferences.current,
    builder: (context, currency, _) =>
        Text(currency.format(amount), style: style),
  );
}
