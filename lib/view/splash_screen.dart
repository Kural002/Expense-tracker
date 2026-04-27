import 'package:expense_trace/utilities/app_image_path.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  
  late Animation<double> _bgScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // Main entrance animations
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Subtle breathing/pulse for the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _bgScale = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutQuart),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Immersive Mesh Background
          ScaleTransition(
            scale: _bgScale,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                AppImagePath.splashBg,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. Dark Overlay for Contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // 3. Central Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: Listenable.merge([_mainController, _pulseController]),
                  builder: (context, child) {
                    final pulse = 1.0 + (_pulseController.value * 0.03);
                    return Transform.scale(
                      scale: _logoScale.value * pulse,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        AppImagePath.splash,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),

                // Animated Text Content
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.7),
                            ],
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            "EXPENSE TRACE",
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "FINANCIAL INTELLIGENCE",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 8,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Elegant Footer
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  SizedBox(
                    width: 30,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      minHeight: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Powered by AI Architecture",
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: Colors.white.withValues(alpha: 0.2),
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
