import 'package:flutter/foundation.dart';

import 'categories_data.dart' as custom;

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final custom.Category category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    DateTime? date,
    required this.category,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.label,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      id: data['id'],
      title: data['title'],
      amount: (data['amount'] as num).toDouble(),
      date: DateTime.parse(data['date']),
      category: custom.categoryMap[data['category']] ?? custom.categoryMap['others']!,
    );
  }
}
