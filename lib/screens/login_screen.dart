import 'package:expense_tracker/utilities/app_Image_path.dart';
import 'package:expense_tracker/utilities/app_colors.dart';
import 'package:expense_tracker/widgets/ExpenseFlipper%20.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar_app.dart';
import 'package:expense_tracker/widgets/google_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  void _login() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BottomNavBarApp(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kWhite,
      appBar: AppBar(
        backgroundColor: AppColor.kWhite,
        title: Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Center(
              child: Image.asset(
                AppImagePath.expense,
                height: 400,
                width: 400,
              ),
            ),
            ExpenseFlipper(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 30.0),
        child: GoogleButton(
          onPressed: _login,
        ),
      ),
    );
  }
}
