import 'package:expense_tracker/utilities/app_image_path.dart';
import 'package:expense_tracker/widgets/transaction_flipper.dart';
import 'package:expense_tracker/widgets/google_button.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  void _login() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final user = await _authService.signInWithGoogle();
    
    if (user == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Premium Glowing Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ColorFilter.mode(
                theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                BlendMode.srcOver,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Premium App Icon/Asset
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppImagePath.expense,
                      height: 220,
                      width: 220,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Typographic Title
                  Text(
                    "Master Your\nFinances",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -1,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Track expenses, optimize savings, and secure your financial future perfectly synced to your style.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const TransactionFlipper(),
                  const Spacer(),
                  // Auth Button Area
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: size.width > 600 ? 400 : double.infinity,
                    child: GoogleButton(
                      onPressed: _login,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
