import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/main_shell.dart';

void main() {
  testWidgets('App shows the three navigation tabs', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ExpenseProvider(),
        child: const MaterialApp(home: MainShell()),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
