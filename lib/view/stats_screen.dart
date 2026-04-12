import 'package:expense_tracker/models/categories_data.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/models/report_range.dart';
import 'package:expense_tracker/utilities/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  ReportRange _selectedRange = ReportRange.thisMonth;

  String _getRangeLabel(ReportRange range) {
    if (range == ReportRange.today) return "Today";
    if (range == ReportRange.thisWeek) return "This Week";
    if (range == ReportRange.thisMonth) return "This Month";
    return "All Time";
  }

  void _showTimeFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Select Timeframe",
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 24),
              ...ReportRange.values.map((range) {
                final isSelected = _selectedRange == range;
                return ListTile(
                  onTap: () {
                    setState(() {
                      _selectedRange = range;
                    });
                    Navigator.pop(context);
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(
                    Icons.calendar_month_outlined, 
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  ),
                  title: Text(
                    _getRangeLabel(range),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        actions: [
          Consumer<TransactionProvider>(
            builder: (context, provider, child) => IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_month_outlined,
                    color: theme.colorScheme.primary, size: 20),
              ),
              onPressed: () => _showTimeFilterBottomSheet(context),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          
          final filteredTransactions = provider.transactions.where((tx) {
            switch (_selectedRange) {
              case ReportRange.today:
                return tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day;
              case ReportRange.thisWeek:
                final weekAgo = todayStart.subtract(const Duration(days: 7));
                return tx.date.isAfter(weekAgo);
              case ReportRange.thisMonth:
                return tx.date.year == now.year && tx.date.month == now.month;
              case ReportRange.allTime:
                return true;
            }
          }).toList();

          final filteredExpenses = filteredTransactions
              .where((tx) => tx.type == TransactionType.expense)
              .toList();

          double totalFilteredIncome = 0;
          double totalFilteredExpense = 0;
          for (var tx in filteredTransactions) {
            if (tx.type == TransactionType.income) {
              totalFilteredIncome += tx.amount;
            } else {
              totalFilteredExpense += tx.amount;
            }
          }

          if (filteredTransactions.isEmpty) {
            return _buildEmptyState(context);
          }

          final categoryTotals = _calculateCategoryTotals(filteredExpenses);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildSummaryHero(context, totalFilteredIncome, totalFilteredExpense),
                const SizedBox(height: 30),
                Text(
                  "Spending Distribution",
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 20),
                _buildBarChart(context, categoryTotals, totalFilteredExpense),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Breakdown",
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    Text(
                      "${categoryTotals.length} Categories",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (filteredExpenses.isEmpty)
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     child: Text("No expenses incurred during this period.", style: theme.textTheme.bodyMedium),
                   ),
                ...categoryTotals.entries.map((entry) {
                  final cat = categoryMap.values.firstWhere(
                    (c) => c.label == entry.key,
                    orElse: () => categoryMap['others']!,
                  );
                  final percentage = (entry.value / totalFilteredExpense) * 100;
                  return _buildModernStatItem(
                      context, cat, entry.value, percentage);
                }),
                const SizedBox(height: 100), // Spacing for floating navbar
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryHero(BuildContext context, double income, double expense) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_getRangeLabel(_selectedRange)} Spending",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${expense.toStringAsFixed(0)}",
            style: theme.textTheme.displayLarge
                ?.copyWith(color: Colors.white, fontSize: 36),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniStat(
                  context,
                  "Income",
                  "₹${income.toStringAsFixed(0)}",
                  Icons.arrow_upward),
              const SizedBox(width: 20),
              _buildMiniStat(
                  context,
                  "Expenses",
                  "₹${expense.toStringAsFixed(0)}",
                  Icons.arrow_downward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, Map<String, double> data, double total) {
    if (data.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    double maxY = data.values.isEmpty ? 10 : data.values.reduce((a, b) => a > b ? a : b);
    
    // Sort to show top spending first
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Limit to 5 bars for a clean UI
    final displayData = sortedData.take(5).toList();

    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 final entry = displayData[group.x];
                 return BarTooltipItem(
                   "₹${rod.toY.toStringAsFixed(0)}\n",
                   theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                   children: <TextSpan>[
                     TextSpan(
                       text: entry.key,
                       style: theme.textTheme.bodySmall!.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                     ),
                   ],
                 );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= displayData.length) return const SizedBox.shrink();
                  final entry = displayData[value.toInt()];
                  final cat = categoryMap.values.firstWhere(
                    (c) => c.label == entry.key,
                    orElse: () => categoryMap['others']!,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                       padding: const EdgeInsets.all(6),
                       decoration: BoxDecoration(
                         color: cat.color.withValues(alpha: 0.1),
                         shape: BoxShape.circle,
                       ),
                       child: Icon(cat.icon, color: cat.color, size: 16),
                    )
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: displayData.asMap().entries.map((entry) {
            final idx = entry.key;
            final dataEntry = entry.value;
            final cat = categoryMap.values.firstWhere(
              (c) => c.label == dataEntry.key,
              orElse: () => categoryMap['others']!,
            );
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: dataEntry.value,
                  color: cat.color,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModernStatItem(
      BuildContext context, Category cat, double amount, double percentage) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(cat.icon, color: cat.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat.label,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹${amount.toStringAsFixed(0)}",
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List transactions) {
    Map<String, double> totals = {};
    for (var tx in transactions) {
      final label = tx.category.label;
      totals[label] = (totals[label] ?? 0) + tx.amount;
    }
    return totals;
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined,
              size: 100,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          const SizedBox(height: 24),
          Text(
            "No data to analyze yet",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Add some transactions to see your spending insights",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
