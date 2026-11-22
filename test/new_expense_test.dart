import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Expense existingExpense({DateTime? date}) => Expense(
  id: 'existing-expense',
  title: 'Cinema',
  amount: 25,
  date: date ?? DateTime(2026, 1, 15),
  category: Category.Entertainment,
  note: 'Original note',
);

Future<void> openForm(
  WidgetTester tester, {
  Expense? expense,
  required void Function(Expense) onSave,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => NewExpense(expense: expense, onSave: onSave),
              ),
              child: const Text('Dashboard'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Dashboard'));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> chooseDate(WidgetTester tester) async {
  await tapVisible(tester, find.byTooltip('Select date'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('empty submission shows inline errors without saving', (
    tester,
  ) async {
    final saved = <Expense>[];
    await openForm(tester, onSave: saved.add);
    await tester.enterText(find.byType(TextFormField).at(0), '   ');
    await tapVisible(tester, find.text('Save Expense'));

    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(
      find.text('Enter a valid amount greater than zero.'),
      findsOneWidget,
    );
    expect(find.text('Please select a date.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(saved, isEmpty);
  });

  for (final amount in [
    '',
    'abc',
    '0',
    '-5',
    'NaN',
    'Infinity',
    '-Infinity',
    '1e309',
  ]) {
    testWidgets('rejects invalid amount "$amount"', (tester) async {
      final saved = <Expense>[];
      await openForm(tester, expense: existingExpense(), onSave: saved.add);
      await tester.enterText(find.byType(TextFormField).at(1), amount);
      await tapVisible(tester, find.text('Update Expense'));

      expect(
        find.text('Enter a valid amount greater than zero.'),
        findsOneWidget,
      );
      expect(saved, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }

  testWidgets('add trims input, accepts optional note, and closes only on OK', (
    tester,
  ) async {
    final saved = <Expense>[];
    await openForm(tester, onSave: saved.add);
    await tester.enterText(find.byType(TextFormField).at(0), '  Lunch  ');
    await tester.enterText(find.byType(TextFormField).at(1), ' 12.50 ');
    await tester.enterText(find.byType(TextFormField).at(2), '   ');
    await chooseDate(tester);
    expect(find.text('Please select a date.'), findsNothing);
    await tapVisible(tester, find.text('Save Expense'));

    expect(saved, hasLength(1));
    expect(saved.single.id, isNotEmpty);
    expect(saved.single.title, 'Lunch');
    expect(saved.single.amount, 12.5);
    expect(saved.single.category, Category.Food);
    expect(saved.single.note, isNull);
    expect(DateUtils.isSameDay(saved.single.date, DateTime.now()), isTrue);
    expect(find.text('Expense saved'), findsOneWidget);
    expect(find.byType(NewExpense), findsOneWidget);

    // Neither tapping the barrier nor system Back dismisses the confirmation.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Expense saved'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(NewExpense), findsNothing);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(saved, hasLength(1));
  });

  testWidgets('edit is prefilled and saves a new value with the original ID', (
    tester,
  ) async {
    final original = existingExpense();
    final saved = <Expense>[];
    await openForm(tester, expense: original, onSave: saved.add);
    expect(find.text('Cinema'), findsOneWidget);
    expect(find.text('Original note'), findsOneWidget);
    expect(find.text('ENTERTAINMENT'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '  Dinner ');
    await tester.enterText(find.byType(TextFormField).at(1), '42');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '  With friends  ',
    );
    await tapVisible(tester, find.byType(DropdownButtonFormField<Category>));
    await tester.tap(find.text('FOOD').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Update Expense'));

    expect(saved, hasLength(1));
    expect(saved.single.id, original.id);
    expect(saved.single.title, 'Dinner');
    expect(saved.single.amount, 42);
    expect(saved.single.note, 'With friends');
    expect(saved.single.date, original.date);
    expect(saved.single.category, Category.Food);
    expect(original.title, 'Cinema');
    expect(original.amount, 25);
    expect(find.text('Expense updated'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(NewExpense), findsNothing);
  });

  testWidgets('rapid double submission calls onSave once', (tester) async {
    final saved = <Expense>[];
    await openForm(tester, expense: existingExpense(), onSave: saved.add);
    final button = find.text('Update Expense');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(saved, hasLength(1));
    expect(find.text('Expense updated'), findsOneWidget);
  });

  for (final editing in [false, true]) {
    testWidgets('Cancel leaves provider unchanged (editing: $editing)', (
      tester,
    ) async {
      final provider = ExpenseProvider();
      addTearDown(provider.dispose);
      final original = existingExpense();
      provider.addExpense(original);
      await openForm(
        tester,
        expense: editing ? original : null,
        onSave: editing ? provider.updateExpense : provider.addExpense,
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Unsaved change',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '99');
      await tapVisible(tester, find.text('Cancel'));
      expect(find.byType(NewExpense), findsNothing);
      expect(provider.expenses, [original]);
      final restored = ExpenseProvider();
      addTearDown(restored.dispose);
      await restored.load();
      expect(restored.expenses, hasLength(1));
      expect(restored.expenses.single.title, 'Cinema');
      expect(restored.expenses.single.amount, 25);
    });
  }

  testWidgets('date picker Cancel preserves an existing date', (tester) async {
    final saved = <Expense>[];
    final original = existingExpense();
    await openForm(tester, expense: original, onSave: saved.add);
    await tapVisible(tester, find.byTooltip('Select date'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Update Expense'));
    expect(saved.single.date, original.date);
  });

  testWidgets(
    'date picker accepts an existing date outside its default range',
    (tester) async {
      await openForm(
        tester,
        expense: existingExpense(date: DateTime(2000)),
        onSave: (_) {},
      );
      await tapVisible(tester, find.byTooltip('Select date'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Back closes an unsaved form without invoking onSave', (
    tester,
  ) async {
    final saved = <Expense>[];
    await openForm(tester, onSave: saved.add);
    await tester.enterText(find.byType(TextFormField).first, 'Unsaved');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(NewExpense), findsNothing);
    expect(saved, isEmpty);
  });

  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    for (final editing in [false, true]) {
      testWidgets('form fits $size with keyboard (editing: $editing)', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewInsets);
        final saved = <Expense>[];
        await openForm(
          tester,
          expense: editing ? existingExpense() : null,
          onSave: saved.add,
          textScale: 1.3,
        );
        await tester.enterText(find.byType(TextFormField).at(0), 'Lunch');
        await tester.enterText(find.byType(TextFormField).at(1), '15');
        if (!editing) await chooseDate(tester);
        await tapVisible(
          tester,
          find.byType(DropdownButtonFormField<Category>),
        );
        await tester.tap(find.text('ENTERTAINMENT').last);
        await tester.pumpAndSettle();
        await tester.showKeyboard(find.byType(TextFormField).at(2));
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        await tester.pumpAndSettle();
        final button = find.text(editing ? 'Update Expense' : 'Save Expense');
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(tester.getBottomRight(button).dy, lessThan(size.height - 250));
        expect(tester.takeException(), isNull);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(saved, hasLength(1));
        expect(saved.single.category, Category.Entertainment);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(find.byType(NewExpense), findsNothing);
      });
    }
  }
}
