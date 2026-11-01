import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Category { Food, Transport, Shopping, Bills, Entertainment, Health, Other }

const categoryIcons = {
  Category.Food: Icons.lunch_dining,
  Category.Transport: Icons.directions_bus,
  Category.Shopping: Icons.shopping_bag,
  Category.Bills: Icons.receipt_long,
  Category.Entertainment: Icons.sports_esports,
  Category.Health: Icons.health_and_safety,
  Category.Other: Icons.more_horiz,
};

class Expense {
  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final String? note; // optional

  String get formattedDate {
    return formatter.format(date);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category.name,
    'note': note,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: Category.values.byName(json['category'] as String),
      note: json['note'] as String?,
    );
  }
}
