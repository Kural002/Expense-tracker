import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/utilities/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum TransactionFilter { all, weekly, monthly }

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Transaction History",
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(context),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final filteredTransactions =
                    _filterTransactions(provider.transactions);

                if (filteredTransactions.isEmpty) {
                  return _buildEmptyState(context);
                }

                final groupedTransactions =
                    _groupTransactionsByDate(filteredTransactions);
                final sortedDates = groupedTransactions.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: sortedDates.length + 1, // Add space for navbar
                  itemBuilder: (context, index) {
                    if (index == sortedDates.length) {
                      return const SizedBox(height: 100);
                    }
                    final date = sortedDates[index];
                    final txs = groupedTransactions[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            _formatDateHeader(date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        ...txs.map((tx) => _buildTransactionItem(context, tx, provider)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip("All", TransactionFilter.all),
          const SizedBox(width: 10),
          _buildFilterChip("Weekly", TransactionFilter.weekly),
          const SizedBox(width: 10),
          _buildFilterChip("Monthly", TransactionFilter.monthly),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case TransactionFilter.weekly:
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return transactions.where((tx) => tx.date.isAfter(sevenDaysAgo)).toList();
      case TransactionFilter.monthly:
        return transactions
            .where((tx) => tx.date.month == now.month && tx.date.year == now.year)
            .toList();
      case TransactionFilter.all:
        return transactions;
    }
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions) {
    Map<DateTime, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(tx);
    }
    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return "Today";
    if (date == yesterday) return "Yesterday";
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  Widget _buildTransactionItem(BuildContext context, Transaction tx, TransactionProvider provider) {
    final theme = Theme.of(context);
    final isIncome = tx.type == TransactionType.income;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Warning",
                style: theme.textTheme.titleLarge,
              ),
              content: Text(
                "Are you sure you want to delete this transaction? This action cannot be undone.",
                style: theme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Cancel",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Delete",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) => provider.deleteTransaction(tx.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade700),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tx.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tx.category.icon, color: tx.category.color, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tx.category.label,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncome ? '+' : '-'} ₹${tx.amount.toStringAsFixed(0)}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    tx.paymentType.name.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded,
              size: 80, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Text(
            "No transactions found",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
