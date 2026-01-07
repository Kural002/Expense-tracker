import 'package:expense_tracker/models/payment_type.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();
  List<Expense> _expenses = [];
  PaymentType _paymentType = PaymentType.upi;

  PaymentType get paymentType => _paymentType;

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

  void setPaymentType(PaymentType value) {
    _paymentType = value;
    notifyListeners();
  }
}
