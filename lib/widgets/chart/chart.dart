import 'package:expense_tracker/models/categories_data.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/widgets/chart/chart_bar.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  const Chart({super.key, required this.transactions});

  final List<Transaction> transactions;

  List<Transaction> get _expenses =>
      transactions.where((tx) => tx.type == TransactionType.expense).toList();

  Map<String, double> get buckets {
    final Map<String, double> bucketMap = {};

    for (var tx in _expenses) {
      final label = tx.category.label;
      bucketMap[label] = (bucketMap[label] ?? 0) + tx.amount;
    }

    return bucketMap;
  }

  double get maxTotalExpense {
    if (buckets.isEmpty) return 0;
    return buckets.values.reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final bucketEntries = buckets.entries.toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bucketEntries.map((entry) {
                return ChartBar(
                  fill: maxTotalExpense == 0 ? 0 : entry.value / maxTotalExpense,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: bucketEntries.map((entry) {
              final cat = categoryMap.values.firstWhere(
                (c) => c.label == entry.key,
                orElse: () => categoryMap['others']!,
              );
              return SizedBox(
                width: 40, // Match ChartBar (32) + padding (8)
                child: Icon(
                  cat.icon,
                  size: 18,
                  color: cat.color.withValues(alpha: 0.7),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
