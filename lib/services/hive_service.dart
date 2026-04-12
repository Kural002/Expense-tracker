import 'package:hive/hive.dart';
import '../models/transaction.dart';

class HiveService {
  final Box<Transaction> transactionBox = Hive.box<Transaction>('transactions');

  Future<void> addTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  Future<List<Transaction>> getTransactions() async {
    return transactionBox.values.toList();
  }

  Future<void> deleteTransaction(String id) async {
    await transactionBox.delete(id);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  Future<void> clearAll() async {
    await transactionBox.clear();
  }
}
