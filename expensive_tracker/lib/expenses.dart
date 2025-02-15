import 'package:expensive_tracker/wigets/expenses_list/expenses_list.dart';
import 'package:expensive_tracker/models/expense.dart';
import 'package:expensive_tracker/wigets/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Flutter course',
      amount: 6.55,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'Project',
      amount: 1000,
      date: DateTime.now(),
      category: Category.leisure,
    ),
  ];

  void _openAddExpenseOvlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (cxt) => NewExpense(onAddExpense: _AddExpense ,),
    );
  }

  void _AddExpense(Expense expense){
    setState(() {
      _registeredExpenses.add(expense);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Flutter ExpenseTracker',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed:  _openAddExpenseOvlay,
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Text('The Chart'),
          const SizedBox(height: 15),
          Expanded(
            child: ExpensesList(
              expenses: _registeredExpenses,
            ),
          ),
        ],
      ),
    );
  }
}
