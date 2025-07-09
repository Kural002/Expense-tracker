import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    _firestoreService.getExpenses().listen((event) {
      _expenses = event;
      notifyListeners();
    });
  }

  void deleteExpense(String id) {
    _firestoreService.deleteExpense(id);
  }

  void addExpense(Expense expense) {
    _firestoreService.addExpense(expense);
  }
}
