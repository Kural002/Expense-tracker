import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/payment_type.dart';
import 'package:expense_tracker/utilities/expense_provider.dart';
import 'package:expense_tracker/view/splash_screen.dart';
import 'package:expense_tracker/services/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(PaymentTypeAdapter());

  await Hive.openBox<Expense>('expenses');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
          primaryColor: Colors.grey.shade300,
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
          )),
      home: const SplashScreen(),
    );
  }
}
