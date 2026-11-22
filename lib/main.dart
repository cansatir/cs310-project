import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/auth/login_screen.dart';
import 'package:expense_tracker/settings/currency_preferences.dart';
import 'package:expense_tracker/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CurrencyPreferences.load();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..load(),
      child: const SpendWiseApp(),
    ),
  );
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SpendWise',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const LoginScreen(),
  );
}
