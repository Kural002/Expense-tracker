import 'package:flutter/material.dart';

import 'package:expense_tracker/widgets/chart/chart_bar.dart';
import 'package:expense_tracker/models/expense.dart';

class Chart extends StatelessWidget {
  Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  Map<String, double> get buckets {
    final Map<String, double> bucketMap = {
      'food': 0,
      'transportation': 0,
      'entertainment': 0,
      'utilities': 0,
      'others': 0,
    };

  for (final expense in expenses) {
  final category = expense.category.label;
  if (bucketMap.containsKey(category)) {
    bucketMap[category] = bucketMap[category]! + expense.amount;
  } else {
    bucketMap['others'] = bucketMap['others']! + expense.amount;
  }
}


    return bucketMap;
  }

  double get maxTotalExpense {
    return buckets.values.isEmpty
        ? 0
        : buckets.values.reduce((a, b) => a > b ? a : b);
  }

  final Map<String, IconData> categoryIcons = {
    'food': Icons.fastfood,
    'transportation': Icons.directions_car,
    'entertainment': Icons.movie,
    'utilities': Icons.lightbulb,
    'others': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.entries.map((entry) {
                final totalExpense = entry.value;
                return ChartBar(
                  fill:
                      maxTotalExpense == 0 ? 0 : totalExpense / maxTotalExpense,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: buckets.keys.map((category) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    categoryIcons[category],
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
