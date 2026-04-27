import 'package:expense_trace/utilities/app_image_path.dart';
import 'package:expense_trace/widgets/transaction_flipper.dart';
import 'package:expense_trace/widgets/google_button.dart';
import 'package:flutter/material.dart';
import 'package:expense_trace/view/main_navigation_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final user = await _authService.signInWithGoogle();

      if (user == null && mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
                'Login failed. Ensure "google-services.json" is in android/app/ and SHA-1 is in Firebase.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
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
                    child: Column(
                      children: [
                        GoogleButton(
                          onPressed: _login,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Temporary bypass for testing
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MainNavigationScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                          child: Text(
                            "Continue as Guest",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
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
