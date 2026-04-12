import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/hive_service.dart';
import '../models/transaction.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _authService = AuthService();
  final _hiveService = HiveService();

  Future<void> addTransaction(Transaction transaction) async {
    final user = _authService.currentUser;

    if (user == null) return;

    await _hiveService.addTransaction(transaction);

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  Stream<List<Transaction>> getTransactions() {
    final user = _authService.currentUser;
    if (user == null) return Stream<List<Transaction>>.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map<List<Transaction>>((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromMap(doc.data()))
            .where((tx) => tx.deletedAt == null) // Show only active items
            .toList());
  }

  Future<void> deleteTransaction(String id) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _hiveService.deleteTransaction(id);
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  Future<void> restoreTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final transaction = Transaction.fromMap(data);
    await _hiveService.addTransaction(transaction);
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .set(data);
  }

  Future<void> deleteAllTransactions() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .get();

    WriteBatch batch = _db.batch();
    final now = DateTime.now().toIso8601String();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'deletedAt': now});
    }
    
    await batch.commit();
    // We keep Hive in sync by clearing it (or updating it)
    await _hiveService.clearAll(); 
  }

  Future<void> undoDeleteAllTransactions() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .where('deletedAt', isNull: false)
        .get();

    WriteBatch batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'deletedAt': null});
    }
    
    await batch.commit();
    // No need to manually update Hive here as the stream will rebuild and Hive will eventually sync
  }
}
