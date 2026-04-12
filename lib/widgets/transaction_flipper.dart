import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:intl/intl.dart'; // For currency formatting

class TransactionFlipper extends StatefulWidget {
  const TransactionFlipper({super.key});

  @override
  State<TransactionFlipper> createState() => _TransactionFlipperState();
}

class _TransactionFlipperState extends State<TransactionFlipper> {
  late Stream<double> _expenseStream;

  @override
  void initState() {
    super.initState();
    _expenseStream = Stream.periodic(
      const Duration(seconds: 2),
      (count) => (count % 2 == 0 ? 150.75 : -75.25), // Simulated expense/income updates
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _expenseStream,
      initialData: 0.0,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0.0;
        final currencyFormatter = NumberFormat.currency(
          symbol: '₹', // Change symbol based on currency
          decimalDigits: 2,
        );

        final theme = Theme.of(context);
        return AnimatedFlipCounter(
          value: value,
          fractionDigits: 2,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          prefix: currencyFormatter.currencySymbol,
          textStyle: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: value >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
        );
      },
    );
  }
}
