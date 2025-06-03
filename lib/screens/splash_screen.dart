import 'dart:async';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/screens/on_boarding_screen.dart';
import 'package:expense_tracker/utilities/app_Image_path.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              user != null ? BottomNavBarApp() : OnBoardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(AppImagePath.splash),
              height: 180,
              fit: BoxFit.contain,
            ),
          
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
