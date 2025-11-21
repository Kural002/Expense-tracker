import 'package:flutter/material.dart';

class Category {
  final String label;
  final IconData icon;
  final Color color;

  const Category(
      {required this.label, required this.icon, required this.color});
}

final Map<String, Category> categoryMap = {
  'food': const Category(
    label: 'food',
    icon: Icons.fastfood,
    color: Colors.orange,
  ),
  'transportation': const Category(
    label: 'transportation',
    icon: Icons.directions_car,
    color: Colors.blue,
  ),
  'entertainment': const Category(
    label: 'entertainment',
    icon: Icons.movie,
    color: Colors.purple,
  ),
  'utilities': const Category(
    label: 'utilities',
    icon: Icons.lightbulb,
    color: Colors.yellow,
  ),
  'friends': const Category(
    label: 'friends',
    icon: Icons.group,
    color: Colors.green,
  ),
  'others': const Category(
    label: 'others',
    icon: Icons.more_horiz,
    color: Colors.grey,
  ),
};
