import 'package:expense_trace/models/transaction_type.dart';
import 'package:hive/hive.dart';
import 'package:expense_trace/models/payment_type.dart';
import 'categories_data.dart' as custom;

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final PaymentType paymentType;

  @HiveField(5)
  final String categoryLabel;

  @HiveField(6)
  final TransactionType type;

  @HiveField(7)
  final DateTime? deletedAt;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.paymentType,
    required this.categoryLabel,
    this.type = TransactionType.expense,
    this.deletedAt,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  custom.Category get category =>
      custom.categoryMap[categoryLabel.toLowerCase()] ?? custom.categoryMap['others']!;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': categoryLabel,
      'paymentType': paymentType.name,
      'type': type.name,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'] ?? '',
      title: data['title'] ?? 'Untitled',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      categoryLabel: (data['category'] ?? 'others').toString().toLowerCase(),
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == data['paymentType'],
        orElse: () => PaymentType.upi,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      deletedAt: data['deletedAt'] != null ? DateTime.parse(data['deletedAt']) : null,
    );
  }
}
