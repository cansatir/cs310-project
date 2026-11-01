import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  static const _storageKey = 'expenses';

  final List<Expense> _expenses = [];
  bool isLoading = true;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalSpent =>
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as List<dynamic>;
        _expenses.addAll(
          decoded.map((e) => Expense.fromJson(e as Map<String, dynamic>)),
        );
      } catch (_) {
        // saved data is broken: start with an empty list instead of crashing
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
    _save();
  }

  void removeExpense(Expense expense) {
    _expenses.remove(expense);
    notifyListeners();
    _save();
  }

  void updateExpense(Expense updated) {
    final index = _expenses.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    _expenses[index] = updated;
    notifyListeners();
    _save();
  }
}
