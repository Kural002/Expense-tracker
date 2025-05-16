import 'package:expense_tracker/models/categories_data.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/custom_textfield/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  void _addExpenseDialog(BuildContext context) {
    final _titleController = TextEditingController();
    final _amountController = TextEditingController();
    DateTime? _selectedDate;
    final _dateController = TextEditingController();
    Category _selectedCategory = categoryMap['others']!;

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade50,
            title: const Text("Add Expense",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: "Title",
                  onChanged: (value) {
                    _titleController.text = value;
                  },
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: _amountController,
                  label: "Amount",
                  onChanged: (value) {
                    _amountController.text = value;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    labelStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  items: categoryMap.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedCategory = value;
                    }
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Date",
                    labelStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      _selectedDate = selectedDate;
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final amountText = _amountController.text.trim();
                  final amount = double.tryParse(amountText);

                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                      ),
                    );
                    return;
                  }

                  final expense = Expense(
                    id: const Uuid().v4(),
                    title: _titleController.text.trim(),
                    amount: amount,
                    date: _selectedDate ?? DateTime.now(),
                    category: _selectedCategory,
                  );

                  _firestoreService.addExpense(expense);
                  Navigator.pop(context);
                },
                child: Text("Add",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: const Text(
          "Expenses",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.logout,
                color: Colors.grey.shade700,
              ))
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final expenses = snapshot.data!;
          return Column(
            spacing: 10,
            children: [
              SizedBox(
                height: 200,
                child: Chart(
                  expenses: expenses,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (_, i) {
                    final e = expenses[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(e.title.toUpperCase()),
                        subtitle: Column(
                          spacing: 2,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("₹${e.amount.toStringAsFixed(2)}"),
                            Row(
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd').format(e.date),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  e.category.label.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[800]),
                          onPressed: () {
                            _firestoreService.deleteExpense(e.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Expense deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: Colors.grey.shade50,
                                  onPressed: () {
                                    _firestoreService.addExpense(
                                      Expense(
                                        id: e.id,
                                        title: e.title,
                                        amount: e.amount,
                                        date: e.date,
                                        category: e.category,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Expense restored',
                                          style: TextStyle(
                                              color: Colors.grey.shade50),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black.withOpacity(0.2),
        onPressed: () => _addExpenseDialog(context),
        child: Icon(
          Icons.add,
          color: Colors.grey.shade50,
        ),
      ),
    );
  }
}
