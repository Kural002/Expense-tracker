import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:expense_tracker/models/categories_data.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/view/expense_screen.dart';
import 'package:expense_tracker/view/home_screen.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/custom_textfield/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class BottomNavBarApp extends StatefulWidget {
  @override
  _BottomNavBarAppState createState() => _BottomNavBarAppState();
}

class _BottomNavBarAppState extends State<BottomNavBarApp> {
  int _selectedIndex = 0;
  final _firestoreService = FirestoreService();
  DateTime selectedMonth = DateTime.now();

  final List<Widget> _pages = [
    HomeScreen(),
    ExpenseScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();

    DateTime? selectedDate;
    Category selectedCategory = categoryMap['others']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -3),
                  )
                ],
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Add Expense",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: titleController,
                      label: "Title",
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: amountController,
                      label: "Amount",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: CustomDropdown<String>(
                        items: categoryMap.values
                            .map((category) => category.label)
                            .toList(),
                        initialItem: selectedCategory.label,
                        onChanged: (selectedLabel) {
                          selectedCategory = categoryMap.values.firstWhere(
                            (category) => category.label == selectedLabel,
                            orElse: () => categoryMap['others']!,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: _dateInputDecoration(),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                          dateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final amount =
                              double.tryParse(amountController.text.trim());

                          if (titleController.text.trim().isEmpty ||
                              amount == null ||
                              amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please fill all the fields properly'),
                              ),
                            );
                            return;
                          }

                          final expense = Expense(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            amount: amount,
                            date: selectedDate ?? DateTime.now(),
                            category: selectedCategory,
                          );

                          _firestoreService.addExpense(expense);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Add",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dateInputDecoration() {
    return InputDecoration(
      labelText: "${DateFormat('yyyy-MM-dd').format(DateTime.now())} ",
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  void _handleFABPressed() async {
    if (_selectedIndex == 0) {
      _showAddExpenseDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _handleFABPressed,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.add,
                size: 25,
                color: Colors.grey.shade800,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade100,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_max_rounded,
                          color:
                              _selectedIndex == 0 ? Colors.black : Colors.grey),
                      Text(
                        "Home",
                        style: TextStyle(
                          color:
                              _selectedIndex == 0 ? Colors.black : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.track_changes_rounded,
                          color:
                              _selectedIndex == 1 ? Colors.black : Colors.grey),
                      Text(
                        "Expenses",
                        style: TextStyle(
                          color:
                              _selectedIndex == 1 ? Colors.black : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
