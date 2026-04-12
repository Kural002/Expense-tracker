import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget {
  const ChartBar({
    super.key,
    required this.fill,
  });

  final double fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 32,
        child: FractionallySizedBox(
          heightFactor: fill.clamp(0.01, 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF818CF8),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
