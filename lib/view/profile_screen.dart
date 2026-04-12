import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/utilities/export_helper.dart';
import 'package:expense_tracker/utilities/theme_provider.dart';
import 'package:expense_tracker/utilities/transaction_provider.dart';
import 'package:expense_tracker/widgets/safe_delete_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildIdentitySection(context, user),
            const SizedBox(height: 32),
            _buildFinancialSnapshot(context),
            const SizedBox(height: 32),
            _buildActionList(context, authService),
            const SizedBox(height: 100), // Spacing for floating navbar
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context, User? user) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null ? const Icon(Icons.person, size: 50) : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? "User Name",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? "email@example.com",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSnapshot(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Financial Snapshot",
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(context, "Total Balance", "₹${provider.totalBalance.toStringAsFixed(0)}", theme.colorScheme.primary),
                  _buildStatItem(context, "Savings Rate", "${_calculateSavingsRate(provider)}%", theme.colorScheme.secondary),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  String _calculateSavingsRate(TransactionProvider provider) {
    if (provider.totalIncome == 0) return "0";
    final savings = provider.totalIncome - provider.totalExpense;
    if (savings <= 0) return "0";
    return ((savings / provider.totalIncome) * 100).toStringAsFixed(0);
  }

  Widget _buildActionList(BuildContext context, AuthService authService) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildActionTile(
          context,
          icon: Icons.file_download_outlined,
          title: "Download Full Report",
          subtitle: "Get all history in PDF",
          onTap: () {
            final provider = Provider.of<TransactionProvider>(context, listen: false);
            ExportHelper.showExportOptions(context, provider);
          },
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          icon: Icons.palette_outlined,
          title: "Appearance",
          subtitle: "App Theme and Personalization",
          onTap: () => _showAppearanceSettings(context),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          icon: Icons.delete_forever_rounded,
          title: "Wipe All Data",
          subtitle: "Permanently delete all records",
          color: Colors.redAccent,
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false, // Force them to read the warning
              builder: (context) => SafeDeleteDialog(
                onConfirm: () async {
                  final provider = Provider.of<TransactionProvider>(context, listen: false);
                  await provider.deleteAllTransactions();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("All data has been cleared."),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 10), // Give them time to undo
                        action: SnackBarAction(
                          label: "UNDO",
                          textColor: theme.colorScheme.primary,
                          onPressed: () async {
                            await provider.undoDeleteAllTransactions();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Data restored successfully.")),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          icon: Icons.logout_rounded,
          title: "Sign Out",
          subtitle: "Safely leave your account",
          color: Colors.redAccent,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text("Sign Out", style: theme.textTheme.titleLarge),
                content: Text("Are you sure you want to sign out of your account?", style: theme.textTheme.bodyMedium),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context); // Close dialog
                      await authService.signOut();
                    },
                    child: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final tileColor = color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tileColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tileColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }

  void _showAppearanceSettings(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Appearance Settings",
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 24),
              _buildThemeOption(context, "System Default", ThemeMode.system, Icons.brightness_auto_rounded, themeProvider),
              _buildThemeOption(context, "Light Mode", ThemeMode.light, Icons.light_mode_rounded, themeProvider),
              _buildThemeOption(context, "Dark Mode", ThemeMode.dark, Icons.dark_mode_rounded, themeProvider),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String label, ThemeMode mode, IconData icon, ThemeProvider provider) {
    final theme = Theme.of(context);
    final isSelected = provider.themeMode == mode;

    return ListTile(
      onTap: () {
        provider.setThemeMode(mode);
        Navigator.pop(context);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
    );
  }
}
