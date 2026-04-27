import 'dart:async';
import 'package:expense_trace/models/payment_type.dart';
import 'package:expense_trace/models/transaction_type.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';

class TransactionProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();
  List<Transaction> _transactions = [];
  PaymentType _paymentType = PaymentType.upi;
  
  StreamSubscription<List<Transaction>>? _transactionSubscription;
  StreamSubscription<User?>? _authSubscription;

  PaymentType get paymentType => _paymentType;
  List<Transaction> get transactions => _transactions;

  TransactionProvider() {
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startListeningToTransactions();
      } else {
        _stopListeningToTransactions();
        _transactions = [];
        notifyListeners();
      }
    });
  }

  void _startListeningToTransactions() {
    _transactionSubscription?.cancel();
    _transactionSubscription = _firestoreService.getTransactions().listen((List<Transaction> event) {
      _transactions = event..sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });
  }

  void _stopListeningToTransactions() {
    _transactionSubscription?.cancel();
    _transactionSubscription = null;
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void deleteTransaction(String id) {
    _firestoreService.deleteTransaction(id);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _firestoreService.addTransaction(transaction);
  }

  void setPaymentType(PaymentType value) {
    _paymentType = value;
    notifyListeners();
  }

  double get totalBalance {
    double balance = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  double get totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0, (sum, tx) => sum + tx.amount);

  Future<void> deleteAllTransactions() async {
    await _firestoreService.deleteAllTransactions();
  }

  Future<void> undoDeleteAllTransactions() async {
    await _firestoreService.undoDeleteAllTransactions();
  }
}
