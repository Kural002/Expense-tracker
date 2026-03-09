import 'package:hive/hive.dart';
import '../models/expense.dart';

class HiveService {
  final Box<Expense> expenseBox = Hive.box<Expense>('expenses');

  void addExpense(Expense expense) {
    expenseBox.put(expense.id, expense);
  }

  List<Expense> getExpenses() {
    return expenseBox.values.toList();
  }

  void deleteExpense(String id) {
    expenseBox.delete(id);
  }

  void updateExpense(Expense expense) {
    expenseBox.put(expense.id, expense);
  }
}
