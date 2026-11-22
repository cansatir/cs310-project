import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/main_shell.dart';
import 'package:expense_tracker/settings/currency_preferences.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/shared/monthly_total_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ExpenseProvider expenses;
  final now = DateTime.now();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CurrencyPreferences.load();
    expenses = ExpenseProvider();
    await expenses.load();
  });

  tearDown(() => expenses.dispose());

  Future<void> openApp(
    WidgetTester tester, {
    bool login = false,
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: expenses,
        child: login
            ? const SpendWiseApp()
            : MaterialApp(
                theme: AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const MainShell(),
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, String name) => tap(
    tester,
    find.descendant(of: find.byType(NavigationBar), matching: find.text(name)),
  );

  Future<void> action(WidgetTester tester, String title, String action) async {
    await tap(tester, find.byTooltip('Actions for $title'));
    await tap(tester, find.text(action));
  }

  Expense record(
    String title,
    double amount,
    DateTime date,
    Category category,
  ) => Expense(title: title, amount: amount, date: date, category: category);

  testWidgets(
    'currency, add, edit, summary, delete cancellation and deletion integrate',
    (tester) async {
      await openApp(tester);
      await tab(tester, 'Settings');
      await tap(tester, find.widgetWithText(ChoiceChip, 'EUR'));
      expect(CurrencyPreferences.current.value, ExpenseCurrency.eur);
      await tab(tester, 'Dashboard');
      expect(find.text(ExpenseCurrency.eur.format(0)), findsOneWidget);
      await tap(tester, find.text('Add expense'));
      expect(
        tester
            .widget<TextField>(find.byType(TextField).at(1))
            .decoration
            ?.prefixText,
        'EUR ',
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Lunch');
      await tester.enterText(find.byType(TextFormField).at(1), '12.50');
      await tap(tester, find.byTooltip('Select date'));
      await tap(tester, find.text('OK'));
      await tap(tester, find.text('Save Expense'));
      expect(find.text('Expense saved'), findsOneWidget);
      await tap(tester, find.text('OK'));
      expect(expenses.expenses, hasLength(1));
      final id = expenses.expenses.single.id;
      expect(find.byType(ExpenseItem), findsOneWidget);

      await action(tester, 'Lunch', 'Edit');
      await tester.enterText(find.byType(TextFormField).at(1), '20');
      await tap(tester, find.text('Update Expense'));
      await tap(tester, find.text('OK'));
      expect(expenses.expenses.single.id, id);
      expect(expenses.expenses.single.amount, 20);
      await tab(tester, 'Summary');
      expect(
        tester.widget<MonthlyTotalCard>(find.byType(MonthlyTotalCard)).total,
        20,
      );
      expect(find.text(ExpenseCurrency.eur.format(20)), findsNWidgets(2));
      await tab(tester, 'Settings');
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'USD'))
            .onSelected,
        isNull,
      );
      await tab(tester, 'Dashboard');
      await action(tester, 'Lunch', 'Delete');
      await tap(tester, find.text('Cancel'));
      expect(expenses.expenses, hasLength(1));
      await action(tester, 'Lunch', 'Delete');
      await tap(tester, find.widgetWithText(FilledButton, 'Delete'));
      expect(expenses.expenses, isEmpty);
      expect(
        find.text('No expenses yet. Add your first expense.'),
        findsOneWidget,
      );
      await tab(tester, 'Settings');
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'USD'))
            .onSelected,
        isNotNull,
      );
      await tap(tester, find.widgetWithText(ChoiceChip, 'TRY'));
      await tab(tester, 'Summary');
      expect(find.text('No expenses recorded for this month.'), findsOneWidget);
      expect(find.text(ExpenseCurrency.tryLira.format(0)), findsWidgets);
      final restored = ExpenseProvider();
      await restored.load();
      expect(restored.expenses, isEmpty);
      restored.dispose();
    },
  );

  testWidgets('dashboard filters by year/month and sorts newest first', (
    tester,
  ) async {
    expenses.addExpense(
      record('Early', 10, DateTime(now.year, now.month, 1), Category.Food),
    );
    expenses.addExpense(
      record('Latest', 30, DateTime(now.year, now.month, 2), Category.Bills),
    );
    expenses.addExpense(
      record(
        'Last month',
        200,
        DateTime(now.year, now.month - 1, 1),
        Category.Other,
      ),
    );
    expenses.addExpense(
      record(
        'Last year',
        999,
        DateTime(now.year - 1, now.month, 1),
        Category.Other,
      ),
    );
    await openApp(tester);
    expect(
      tester.widget<MonthlyTotalCard>(find.byType(MonthlyTotalCard)).total,
      40,
    );
    await tester.scrollUntilVisible(find.text('Early'), 100);
    expect(
      tester.getTopLeft(find.text('Latest')).dy,
      lessThan(tester.getTopLeft(find.text('Early')).dy),
    );
    expect(find.text('Last month'), findsNothing);
    await tap(tester, find.byTooltip('Previous month'));
    expect(
      tester.widget<MonthlyTotalCard>(find.byType(MonthlyTotalCard)).total,
      200,
    );
    expect(find.text('Last month'), findsOneWidget);
  });

  testWidgets(
    'swipe delete requires confirmation and swipe edit keeps record',
    (tester) async {
      final expense = record('Bus pass', 30, now, Category.Transport);
      expenses.addExpense(expense);
      await openApp(tester);
      await tester.drag(
        find.byKey(ValueKey(expense.id)),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete expense?'), findsOneWidget);
      await tap(tester, find.text('Cancel'));
      expect(expenses.expenses.single.id, expense.id);
      await tester.drag(find.byKey(ValueKey(expense.id)), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.byType(NewExpense), findsOneWidget);
      await tap(tester, find.text('Cancel'));
      expect(expenses.expenses, hasLength(1));
      await tester.drag(
        find.byKey(ValueKey(expense.id)),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.widgetWithText(FilledButton, 'Delete'));
      expect(expenses.expenses, isEmpty);
    },
  );

  testWidgets('valid signup opens shell and Back does not return to auth', (
    tester,
  ) async {
    await openApp(tester, login: true);
    await tap(tester, find.text("Don't have an account? Sign up"));
    final values = [
      'Demo Student',
      'demo@example.com',
      'password123',
      'password123',
    ];
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), values[i]);
    }
    await tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
    expect(find.byType(MainShell), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Create account'), findsNothing);
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('auth forms remain usable at $size with keyboard', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.reset);
      await openApp(tester, login: true);
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tap(tester, find.widgetWithText(FilledButton, 'Log in'));
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tap(tester, find.text("Don't have an account? Sign up"));
      await tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Confirm password is required'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('all main screens fit $size at 130% text size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      expenses.addExpense(
        record(
          'A long expense title that must wrap across lines',
          12345.67,
          now,
          Category.Entertainment,
        ),
      );
      await openApp(tester, scale: 1.3);
      await tester.scrollUntilVisible(find.byType(ExpenseItem), 150);
      expect(tester.takeException(), isNull);
      await tab(tester, 'Summary');
      await tester.scrollUntilVisible(find.text('Other'), 150);
      expect(tester.takeException(), isNull);
      await tab(tester, 'Settings');
      await tester.scrollUntilVisible(find.text('About'), 150);
      expect(tester.takeException(), isNull);
    });
  }
}
