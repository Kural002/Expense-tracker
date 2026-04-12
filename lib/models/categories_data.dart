import 'package:expense_tracker/models/transaction_type.dart';
import 'package:flutter/material.dart';

class Category {
  final String label;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const Category({
    required this.label,
    required this.icon,
    required this.color,
    this.type = TransactionType.expense,
  });
}

final Map<String, Category> categoryMap = {
  // Expenses
  'food': const Category(
    label: 'Food',
    icon: Icons.fastfood,
    color: Colors.orange,
  ),
  'transportation': const Category(
    label: 'Transportation',
    icon: Icons.directions_car,
    color: Colors.blue,
  ),
  'entertainment': const Category(
    label: 'Entertainment',
    icon: Icons.movie,
    color: Colors.purple,
  ),
  'utilities': const Category(
    label: 'Utilities',
    icon: Icons.lightbulb,
    color: Colors.amber,
  ),
  'shopping': const Category(
    label: 'Shopping',
    icon: Icons.shopping_bag,
    color: Colors.pink,
  ),
  'health': const Category(
    label: 'Health',
    icon: Icons.medical_services,
    color: Colors.red,
  ),
  'education': const Category(
    label: 'Education',
    icon: Icons.school,
    color: Colors.indigo,
  ),
  'others': const Category(
    label: 'Others',
    icon: Icons.more_horiz,
    color: Colors.grey,
  ),

  // Income
  'salary': const Category(
    label: 'Salary',
    icon: Icons.account_balance_wallet,
    color: Colors.green,
    type: TransactionType.income,
  ),
  'freelance': const Category(
    label: 'Freelance',
    icon: Icons.work,
    color: Colors.teal,
    type: TransactionType.income,
  ),
  'investment': const Category(
    label: 'Investment',
    icon: Icons.trending_up,
    color: Colors.lightGreen,
    type: TransactionType.income,
  ),
  'gift': const Category(
    label: 'Gift',
    icon: Icons.card_giftcard,
    color: Colors.cyan,
    type: TransactionType.income,
  ),
};

List<Category> getCategoriesByType(TransactionType type) {
  return categoryMap.values.where((c) => c.type == type).toList();
}
