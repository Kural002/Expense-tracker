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
            ),
          )
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

          final today = DateTime.now();
          final todayExpenses = expenses.where((e) {
            return e.date.year == today.year &&
                e.date.month == today.month &&
                e.date.day == today.day;
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;

              if (isWideScreen) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(child: Chart(expenses: todayExpenses)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildExpenseList(todayExpenses),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTodayHeader(),
                    SizedBox(
                      height: 200,
                      child: Chart(expenses: todayExpenses),
                    ),
                    Expanded(
                      child: _buildExpenseList(todayExpenses),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Text(
          "No expenses today.\nAdd your expense!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: expenses.length,
      itemBuilder: (_, i) {
        final e = expenses[i];
        return Dismissible(
          key: Key(e.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            final deletedExpense = e;

            _firestoreService.deleteExpense(deletedExpense.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Expense deleted"),
                action: SnackBarAction(
                  label: "UNDO",
                  textColor: Colors.white,
                  onPressed: () {
                    _firestoreService.addExpense(deletedExpense);
                  },
                ),
              ),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.red.shade700,
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.category.label.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 11,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 15,
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
                  "₹${e.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildTodayHeader() {
  final now = DateTime.now();

  final dayName = DateFormat('EEEE').format(now);
  final dateText = DateFormat('dd MMM yyyy').format(now);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today",
              style: TextStyle(
                fontSize: 12,
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              dayName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          dateText,
          style: TextStyle(
            fontSize: 14,
            fontFamily: GoogleFonts.poppins().fontFamily,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    ),
  );
}
