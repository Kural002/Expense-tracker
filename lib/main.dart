import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/models/payment_type.dart';
import 'package:expense_tracker/utilities/app_theme.dart';
import 'package:expense_tracker/utilities/theme_provider.dart';
import 'package:expense_tracker/utilities/transaction_provider.dart';
import 'package:expense_tracker/view/splash_screen.dart';
import 'package:expense_tracker/services/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expense_tracker/view/login_screen.dart';
import 'package:expense_tracker/view/main_navigation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(PaymentTypeAdapter());

    await Hive.openBox<Transaction>('transactions');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TransactionProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    logger.e("Critical initialization error: $e");
    // Run minimal app to show error if necessary
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Startup Error: $e")))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    // Add a minimum delay to ensure smooth transition and allow Firebase Auth to settle
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}

