import 'dart:async';
import 'package:flutter/material.dart';

class SafeDeleteDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const SafeDeleteDialog({required this.onConfirm, super.key});

  @override
  State<SafeDeleteDialog> createState() => _SafeDeleteDialogState();
}

class _SafeDeleteDialogState extends State<SafeDeleteDialog> {
  int _secondsRemaining = 5;
  Timer? _timer;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canDelete = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "High-Stakes Action",
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You are about to hide all financial records from your view. Please take a moment to ensure this is what you want.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Data will be retrievable for 30 days. After that, it will be permanently purged.",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: 1 - (_secondsRemaining / 5),
                  strokeWidth: 6,
                  color: _canDelete ? theme.colorScheme.error : theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _canDelete ? "Safety Lock Released" : "Safety Lock: $_secondsRemaining s",
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _canDelete ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _canDelete ? () {
            Navigator.pop(context);
            widget.onConfirm();
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: theme.colorScheme.error.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text("Clear Everything"),
        ),
      ],
    );
  }
}
