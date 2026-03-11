import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:expense_tracker/models/categories_data.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/payment_type.dart';
import 'package:expense_tracker/utilities/expense_provider.dart';
import 'package:expense_tracker/view/expense_screen.dart';
import 'package:expense_tracker/view/home_screen.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/custom_textfield/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BottomNavBarApp extends StatefulWidget {
  @override
  _BottomNavBarAppState createState() => _BottomNavBarAppState();
}

class _BottomNavBarAppState extends State<BottomNavBarApp> {
  int _selectedIndex = 0;
  final _firestoreService = FirestoreService();
  DateTime selectedMonth = DateTime.now();
  final logger = Logger();

  final List<Widget> _pages = [
    HomeScreen(),
    ExpenseScreen(),
  ];

  // ⭐ CHECK INTERNET WHEN APP STARTS
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetOnStart();
    });
  }

  Future<void> _checkInternetOnStart() async {
    final result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("No Internet"),
          content: const Text(
            "You are currently offline. Expenses will sync when internet returns.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

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

                    /// TITLE
                    CustomTextField(
                      controller: titleController,
                      label: "Title",
                    ),
                    const SizedBox(height: 12),

                    /// AMOUNT
                    CustomTextField(
                      controller: amountController,
                      label: "Amount",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    /// CATEGORY
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
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

                    /// DATE
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

                    const SizedBox(height: 12),

                    /// PAYMENT TYPE
                    Consumer<ExpenseProvider>(
                      builder: (context, provider, _) {
                        return CupertinoSlidingSegmentedControl<PaymentType>(
                          groupValue: provider.paymentType,
                          children: const {
                            PaymentType.upi: Text("UPI"),
                            PaymentType.cash: Text("Cash"),
                          },
                          onValueChanged: (value) {
                            if (value != null) {
                              provider.setPaymentType(value);
                              logger.d(
                                  "Selected payment: ${provider.paymentType}");
                            }
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    /// ADD BUTTON
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
                            paymentType:
                                context.read<ExpenseProvider>().paymentType,
                            categoryLabel: selectedCategory.label.toLowerCase(),
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
      labelText: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  void _handleFABPressed() {
    if (_selectedIndex == 0) {
      _showAddExpenseDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _pages[_selectedIndex],

      /// FAB
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _handleFABPressed,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.add, color: Colors.grey.shade800),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// BOTTOM NAV
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade200,
        notchMargin: 8,
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
                      Icon(Icons.home_max_sharp,
                          color:
                              _selectedIndex == 0 ? Colors.black : Colors.grey),
                      Text("Home",
                          style: TextStyle(
                              color: _selectedIndex == 0
                                  ? Colors.black
                                  : Colors.grey)),
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
                      Icon(Icons.bar_chart_rounded,
                          color:
                              _selectedIndex == 1 ? Colors.black : Colors.grey),
                      Text("Expenses",
                          style: TextStyle(
                              color: _selectedIndex == 1
                                  ? Colors.black
                                  : Colors.grey)),
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
