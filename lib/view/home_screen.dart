import 'package:expense_tracker/utilities/expense_provider.dart';
import 'package:expense_tracker/view/on_boarding_screen.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Text(
          "Expense Tracker",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnBoardingScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.logout,
                color: Colors.grey.shade800,
              ))
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
                  padding: const EdgeInsets.all(8),
                  itemCount: expenses.length,
                  itemBuilder: (_, i) {
                    final e = expenses[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.category.label.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd').format(e.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            e.title.toUpperCase(),
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${e.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontFamily: GoogleFonts.roboto().fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.red[800]),
                                onPressed: () {
                                  context
                                      .read<ExpenseProvider>()
                                      .deleteExpense(e.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Expense deleted'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          context
                                              .read<ExpenseProvider>()
                                              .addExpense(e);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
