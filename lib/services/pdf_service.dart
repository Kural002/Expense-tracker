import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static final _indigo = PdfColor.fromHex('#6366F1');
  static final _blue = PdfColor.fromHex('#818CF8');
  static final _green = PdfColor.fromHex('#10B981');
  static final _red = PdfColor.fromHex('#EF4444');
  static final _grey = PdfColor.fromHex('#9CA3AF');

  static Future<void> exportTransactionReport({
    required List<Transaction> transactions,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    String? reportTitle,
    bool isShare = false,
  }) async {
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(dateFormat.format(DateTime.now()), reportTitle),
            pw.SizedBox(height: 24),
            _buildSummaryCards(totalIncome, totalExpense, balance),
            pw.SizedBox(height: 32),
            ..._buildCategoryTable(transactions, totalExpense),
            pw.SizedBox(height: 32),
            ..._buildTransactionTable(transactions, dateFormat),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();
    
    if (isShare) {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Expense_Report_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  static pw.Widget _buildHeader(String date, String? title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'EXPENSE TRACE',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: _indigo,
              ),
            ),
            pw.Text(
              title ?? 'Financial Statement Report',
              style: pw.TextStyle(fontSize: 12, color: _grey),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Generated on:', style: pw.TextStyle(fontSize: 10, color: _grey)),
            pw.Text(date, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCards(double income, double expense, double balance) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard('Total Income', '₹${income.toStringAsFixed(0)}', _green),
        _summaryCard('Total Expense', '₹${expense.toStringAsFixed(0)}', _red),
        _summaryCard('Balance', '₹${balance.toStringAsFixed(0)}', _indigo),
      ],
    );
  }

  static pw.Widget _summaryCard(String title, String amount, PdfColor color) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey200, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, color: _grey)),
          pw.SizedBox(height: 4),
          pw.Text(
            amount,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildCategoryTable(List<Transaction> transactions, double totalExpense) {
    final expenses = transactions.where((tx) => tx.type == TransactionType.expense).toList();
    final totals = <String, double>{};
    for (var tx in expenses) {
      totals[tx.categoryLabel] = (totals[tx.categoryLabel] ?? 0) + tx.amount;
    }

    final data = totals.entries.toList();
    data.sort((a, b) => b.value.compareTo(a.value));

    return [
      pw.Text('Spending by Category',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Category', 'Amount', '% of Total'],
        data: data.map((e) {
          final percentage = totalExpense > 0 ? (e.value / totalExpense) * 100 : 0.0;
          return [
            e.key.toUpperCase(),
            '₹${e.value.toStringAsFixed(0)}',
            '${percentage.toStringAsFixed(1)}%',
          ];
        }).toList(),
        headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
        headerDecoration: pw.BoxDecoration(color: _indigo),
        cellHeight: 25,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerRight,
        },
      ),
    ];
  }

  static List<pw.Widget> _buildTransactionTable(List<Transaction> transactions, DateFormat format) {
    return [
      pw.Text('Detailed Transactions',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 12),
      pw.TableHelper.fromTextArray(
        headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
        data: transactions.map((tx) {
          return [
            format.format(tx.date),
            tx.title,
            tx.categoryLabel.toUpperCase(),
            tx.type.name.toUpperCase(),
            '₹${tx.amount.toStringAsFixed(0)}',
          ];
        }).toList(),
        headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
        headerDecoration: pw.BoxDecoration(color: _blue),
        cellHeight: 25,
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerLeft,
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
        },
      ),
    ];
  }
}
