import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Category {
  final String label;
  final IconData icon;

  const Category({required this.label, required this.icon});
}

final Map<String, Category> categoryMap = {
  'food': const Category(
    label: 'food',
    icon: Icons.fastfood,
  ),
  'transportation': const Category(
    label: 'transportation',
    icon: Icons.directions_car,
  ),
  'entertainment': const Category(
    label: 'entertainment',
    icon: Icons.movie,
  ),
  'utilities': const Category(
    label: 'utilities',
    icon: Icons.lightbulb,
  ),
  'others': const Category(
    label: 'others',
    icon: Icons.more_horiz,
  ),
};

final List<Category> categories = categoryMap.values.toList();
