import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ExpenseCurrency {
  usd('USD'),
  tryLira('TRY'),
  eur('EUR');

  const ExpenseCurrency(this.code);

  final String code;

  String format(double amount, {String? locale}) {
    return NumberFormat.simpleCurrency(
      name: code,
      locale: locale,
    ).format(amount);
  }
}

abstract final class CurrencyPreferences {
  static const _storageKey = 'expense_currency';
  static final _current = ValueNotifier(ExpenseCurrency.usd);

  static ValueListenable<ExpenseCurrency> get current => _current;

  static Future<ExpenseCurrency> load() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(_storageKey);
    final currency = ExpenseCurrency.values.firstWhere(
      (currency) => currency.code == code,
      orElse: () => ExpenseCurrency.usd,
    );
    _current.value = currency;
    return currency;
  }

  static Future<void> save(ExpenseCurrency currency) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(_storageKey, currency.code)) {
      throw StateError('Could not save the expense currency.');
    }
    _current.value = currency;
  }
}
