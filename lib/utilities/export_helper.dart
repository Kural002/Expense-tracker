import 'package:expense_trace/models/report_range.dart';
import 'package:expense_trace/models/transaction.dart';
import 'package:expense_trace/models/transaction_type.dart';
import 'package:expense_trace/utilities/transaction_provider.dart';
import 'package:expense_trace/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportHelper {
  static void showExportOptions(BuildContext context, TransactionProvider provider) {
    final theme = Theme.of(context);
    ReportRange selectedRange = ReportRange.allTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      "Export Report",
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Select Period",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ReportRange.values.map((range) {
                        String label = range.name;
                        if (range == ReportRange.today) label = "Today";
                        if (range == ReportRange.thisWeek) label = "This Week";
                        if (range == ReportRange.thisMonth) label = "This Month";
                        if (range == ReportRange.allTime) label = "All Time";

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: selectedRange == range,
                            onSelected: (selected) {
                              if (selected) setModalState(() => selectedRange = range);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildExportOption(
                    context,
                    theme,
                    icon: Icons.share_rounded,
                    title: "Share Statement",
                    subtitle: "Send via WhatsApp, Email, etc.",
                    color: theme.colorScheme.primary,
                    onTap: () => _executeExport(context, provider, selectedRange, isShare: true),
                  ),
                  const SizedBox(height: 12),
                  _buildExportOption(
                    context,
                    theme,
                    icon: Icons.file_download_rounded,
                    title: "Download PDF",
                    subtitle: "Save report to your device",
                    color: theme.colorScheme.secondary,
                    onTap: () => _executeExport(context, provider, selectedRange, isShare: false),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildExportOption(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
      onTap: onTap,
    );
  }

  static void _executeExport(
    BuildContext context,
    TransactionProvider provider,
    ReportRange range, {
    required bool isShare,
  }) {
    Navigator.pop(context);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    List<Transaction> filteredTransactions;
    String reportTitle;

    switch (range) {
      case ReportRange.today:
        filteredTransactions = provider.transactions
            .where((tx) =>
                tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day)
            .toList();
        reportTitle = "Daily Statement - Today";
        break;
      case ReportRange.thisWeek:
        final weekAgo = todayStart.subtract(const Duration(days: 7));
        filteredTransactions = provider.transactions.where((tx) => tx.date.isAfter(weekAgo)).toList();
        reportTitle = "Weekly Statement - Last 7 Days";
        break;
      case ReportRange.thisMonth:
        filteredTransactions = provider.transactions
            .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
            .toList();
        reportTitle = "Monthly Statement - ${DateFormat('MMMM yyyy').format(now)}";
        break;
      case ReportRange.allTime:
        filteredTransactions = provider.transactions;
        reportTitle = "Full Financial Statement";
        break;
    }

    if (filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No transactions found for the selected period")),
      );
      return;
    }

    double income = 0;
    double expense = 0;
    for (var tx in filteredTransactions) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    PdfService.exportTransactionReport(
      transactions: filteredTransactions,
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
      reportTitle: reportTitle,
      isShare: isShare,
    );
  }
}
