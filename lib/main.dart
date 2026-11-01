import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/main_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..load(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainShell(),
      ),
    ),
  );
}

//test
