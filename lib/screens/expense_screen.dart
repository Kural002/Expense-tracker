import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Tracked Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: buildMonthlyExpensesScreen(selectedMonth)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade300,
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedMonth,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(
              () {
                selectedMonth = DateTime(picked.year, picked.month);
              },
            );
          }
        },
        icon: Icon(Icons.calendar_month, color: Colors.grey.shade800),
        label: Text(
          "Pick Month",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
      ),
    );
  }

  Widget buildMonthlyExpensesScreen(DateTime selectedMonth) {
    return StreamBuilder<QuerySnapshot>(
      stream: getMonthlyExpenses(selectedMonth),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final expenses = snapshot.data!.docs;

        Map<String, List<QueryDocumentSnapshot>> groupedByDate = {};

        for (var doc in expenses) {
          final data = doc.data() as Map<String, dynamic>;
          final date = DateTime.tryParse(data['date'] ?? '');
          if (date == null) continue;

          if (date.year == selectedMonth.year &&
              date.month == selectedMonth.month) {
            final formatted = DateFormat('yyyy-MM-dd').format(date);
            groupedByDate.putIfAbsent(formatted, () => []).add(doc);
          }
        }

        final sortedDates = groupedByDate.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Newest day first

        if (sortedDates.isEmpty) {
          return const Center(child: Text('No expenses found for this month.'));
        }

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dayExpenses = groupedByDate[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d, yyyy')
                            .format(DateTime.parse(date)),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${dayExpenses.fold<double>(0.0, (sum, doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return sum + (data['amount'] as num).toDouble();
                        }).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                ...dayExpenses.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(data['title'] ?? ''),
                      subtitle: Text(
                        data['category']?.toUpperCase() ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                        ),
                      ),
                      trailing: Text(
                        '₹${data['amount']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> getMonthlyExpenses(DateTime selectedMonth) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
