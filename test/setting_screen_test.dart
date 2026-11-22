import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/setting_screen.dart';
import 'package:expense_tracker/settings/currency_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget settingsApp(ExpenseProvider expenses) {
  return ChangeNotifierProvider.value(
    value: expenses,
    child: const MaterialApp(home: SettingScreen()),
  );
}

Finder currencyChip(String code) {
  return find.widgetWithText(ChoiceChip, code);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('currency defaults to USD and formats the unchanged amount', () async {
    expect(await CurrencyPreferences.load(), ExpenseCurrency.usd);
    expect(ExpenseCurrency.eur.format(10, locale: 'en_US'), '€10.00');
  });

  testWidgets('saves a currency and restores it in a fresh Settings screen', (
    tester,
  ) async {
    final expenses = ExpenseProvider();
    await expenses.load();
    await tester.pumpWidget(settingsApp(expenses));
    await tester.pump();
    expect(tester.widget<ChoiceChip>(currencyChip('USD')).selected, isTrue);

    await tester.tap(currencyChip('TRY'));
    await tester.pump();
    await tester.pump();
    expect(CurrencyPreferences.current.value, ExpenseCurrency.tryLira);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(settingsApp(expenses));
    await tester.pump();
    expect(tester.widget<ChoiceChip>(currencyChip('TRY')).selected, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('expense_currency'), 'TRY');
  });

  testWidgets('locks currency with an expense and unlocks when removed', (
    tester,
  ) async {
    final expenses = ExpenseProvider();
    await expenses.load();
    final expense = Expense(
      title: 'Lunch',
      amount: 12,
      date: DateTime(2026, 11, 22),
      category: Category.Food,
    );
    expenses.addExpense(expense);
    await tester.pumpWidget(settingsApp(expenses));
    await tester.pump();

    expect(tester.widget<ChoiceChip>(currencyChip('EUR')).onSelected, isNull);
    expect(find.textContaining('Currency is locked'), findsOneWidget);

    expenses.removeExpense(expense);
    await tester.pump();
    expect(tester.widget<ChoiceChip>(currencyChip('EUR')).onSelected, isNotNull);
  });

  test('bundles the local illustration and custom font', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final image = await rootBundle.load('assets/images/spendwise_mark.png');
    final font = await rootBundle.load('assets/fonts/RobotoMono-Medium.ttf');
    expect(image.lengthInBytes, greaterThan(0));
    expect(font.lengthInBytes, greaterThan(0));
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('Settings fits $size and handles remote image failure', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final expenses = ExpenseProvider();
      await expenses.load();
      await tester.pumpWidget(settingsApp(expenses));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final about = tester.widget<Text>(find.text('About'));
      expect(about.style?.fontFamily, 'RobotoMono');
      expect(
        find.bySemanticsLabel('Chart illustration unavailable'),
        findsOneWidget,
      );
    });
  }
}
