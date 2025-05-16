import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/services/auth_service.dart';
import '../models/expense.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _authService = AuthService();

  Future<void> addExpense(Expense expense) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  Stream<List<Expense>> getExpenses() {
    final user = _authService.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList());
  }

  Future<void> deleteExpense(String id) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(id)
        .delete();
  }
}
