import 'package:hive/hive.dart';
import '../models/expense.dart';

class HiveService {
  final Box<Expense> expenseBox = Hive.box<Expense>('expenses');

  Future<void> addExpense(Expense expense) async {
    await expenseBox.put(expense.id, expense);
  }

  Future<List<Expense>> getExpenses() async {
    return expenseBox.values.toList();
  }

  Future<void> deleteExpense(String id) async {
    await expenseBox.delete(id);
  }

  Future<void> updateExpense(Expense expense) async {
    await expenseBox.put(expense.id, expense);
  }
}
