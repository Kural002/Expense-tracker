import 'package:expense_tracker/models/categories_data.dart';
import 'package:expense_tracker/models/payment_type.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/utilities/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../services/ocr_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? initialAmount;
  final String? initialTitle;

  const AddTransactionScreen({
    super.key,
    this.initialAmount,
    this.initialTitle,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  late Category _selectedCategory;
  PaymentType _selectedPaymentType = PaymentType.upi;
  final _ocrService = OcrService();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _amountController = TextEditingController(text: widget.initialAmount);
    _selectedCategory = getCategoriesByType(TransactionType.expense).first;
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = getCategoriesByType(type).first;
    });
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (_titleController.text.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid details")),
      );
      return;
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      title: _titleController.text,
      amount: amount,
      paymentType: _selectedPaymentType,
      categoryLabel: _selectedCategory.label,
      type: _selectedType,
      date: _selectedDate,
    );

    await context.read<TransactionProvider>().addTransaction(transaction);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _scanBill() async {
    // Choice between Camera and Gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Capture with Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pick from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isScanning = true);
    
    final result = source == ImageSource.camera 
        ? await _ocrService.scanBill() 
        : await _ocrService.pickFromGallery();

    if (mounted) {
      setState(() => _isScanning = false);
      if (result != null) {
        if (result.amount != null) {
          _amountController.text = result.amount!.toStringAsFixed(0);
        }
        if (result.title != null) {
          _titleController.text = result.title!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bill scanned!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan cancelled or failed.")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = getCategoriesByType(_selectedType);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Transaction",
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Selector
            Row(
              children: [
                _buildTypeButton(context, TransactionType.expense, "Expense"),
                const SizedBox(width: 15),
                _buildTypeButton(context, TransactionType.income, "Income"),
              ],
            ),
            const SizedBox(height: 30),

            // Amount Input
            Text(
              "Amount",
              style: theme.textTheme.bodyMedium,
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: theme.textTheme.displayLarge?.copyWith(
                color: colorScheme.primary,
              ),
              decoration: InputDecoration(
                prefixText: "₹ ",
                prefixStyle: theme.textTheme.displayLarge?.copyWith(color: colorScheme.primary),
                suffixIcon: IconButton(
                  onPressed: _isScanning ? null : _scanBill,
                  icon: _isScanning 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.document_scanner_rounded, color: colorScheme.primary, size: 32),
                ),
                border: InputBorder.none,
                hintText: "0",
              ),
            ),
            const SizedBox(height: 20),

            // Title Input
            _buildInputField(context, "Title", _titleController, Icons.edit_note),
            const SizedBox(height: 20),

            // Date Picker
            _buildPickerTile(
              context,
              "Date",
              DateFormat('MMMM dd, yyyy').format(_selectedDate),
              Icons.calendar_today_outlined,
              () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 20),

            // Category Picker
            Text(
              "Category",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory.label == cat.label;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat.icon,
                            color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            cat.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Payment Type
            Text(
              "Payment Method",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildPaymentOption(context, PaymentType.upi, "UPI", Icons.qr_code_scanner),
                const SizedBox(width: 15),
                _buildPaymentOption(context, PaymentType.cash, "Cash", Icons.payments_outlined),
              ],
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text("Save Transaction"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(BuildContext context, TransactionType type, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTypeChanged(type),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? theme.colorScheme.surface : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, TextEditingController controller, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        TextField(
          controller: controller,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
            hintText: "What was it for?",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerTile(BuildContext context, String label, String value, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
                const SizedBox(width: 15),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, PaymentType type, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedPaymentType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
