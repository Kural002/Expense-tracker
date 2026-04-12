import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : Colors.black,
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
             color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.1) : Colors.black12,
          ),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(double.infinity, 54),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/google.png',
            height: 26,
          ),
          const SizedBox(width: 10),
          Text(
            'Sign in with Google',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
