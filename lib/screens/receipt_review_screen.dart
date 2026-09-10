import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bank_statement_models.dart';
import '../providers/finance_provider.dart';
import '../services/category_service.dart';

class ReceiptReviewScreen extends StatefulWidget {
  final ParsedReceipt parsedReceipt;

  const ReceiptReviewScreen({super.key, required this.parsedReceipt});

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);

  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late final TextEditingController _taxController;
  late final TextEditingController _invoiceController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  bool _isSaving = false;

  final List<String> _paymentMethods = [
    'UPI',
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank',
  ];

  @override
  void initState() {
    super.initState();
    final receipt = widget.parsedReceipt;
    _merchantController = TextEditingController(text: receipt.merchant);
    _amountController = TextEditingController(
      text: receipt.amount > 0 ? receipt.amount.toStringAsFixed(2) : '',
    );
    _taxController = TextEditingController(
      text: receipt.tax != null ? receipt.tax!.toStringAsFixed(2) : '',
    );
    _invoiceController = TextEditingController(text: receipt.invoiceNumber ?? '');
    _noteController = TextEditingController(
      text: 'Scanned receipt ${receipt.invoiceNumber != null ? "(Inv #${receipt.invoiceNumber})" : ""}'.trim(),
    );

    _selectedDate = receipt.date;
    _selectedCategory = receipt.category;
    if (!CategoryService.standardCategories.contains(_selectedCategory)) {
      _selectedCategory = 'Other';
    }
    _selectedPaymentMethod = receipt.paymentMethod;
    if (!_paymentMethods.contains(_selectedPaymentMethod)) {
      _selectedPaymentMethod = 'UPI';
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _invoiceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    final merchant = _merchantController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (merchant.isEmpty) {
      _showSnackbar('Please enter a merchant name');
      return;
    }

    if (amount == null || amount <= 0) {
      _showSnackbar('Please enter a valid amount');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tx = widget.parsedReceipt.toFinanceTransaction().copyWith(
            title: merchant,
            merchant: merchant,
            amount: amount,
            category: _selectedCategory,
            paymentMethod: _selectedPaymentMethod,
            date: _selectedDate,
            description: _noteController.text.trim(),
          );

      await context.read<FinanceProvider>().addTransaction(tx);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardColor,
          content: Text(
            'Saved receipt for $merchant (₹${amount.toStringAsFixed(0)})',
            style: const TextStyle(color: green, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Return to previous or dashboard
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackbar('Failed to save receipt: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: red,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confidencePct = (widget.parsedReceipt.confidence * 100).toInt();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Receipt Review',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Detection Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: cyan, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Detected ($confidencePct% confidence) • Review & Edit before saving',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Image Preview if available
            if (widget.parsedReceipt.imagePath != null &&
                File(widget.parsedReceipt.imagePath!).existsSync())
              Center(
                child: Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                    image: DecorationImage(
                      image: FileImage(File(widget.parsedReceipt.imagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Form Fields
            _fieldLabel('Merchant / Store'),
            TextField(
              controller: _merchantController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Merchant Name', Icons.store_outlined),
            ),

            const SizedBox(height: 16),

            _fieldLabel('Total Amount (₹)'),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: _inputDecoration('Total Amount', Icons.currency_rupee_rounded),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Tax / GST (₹)'),
                      TextField(
                        controller: _taxController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Optional Tax', Icons.receipt_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Invoice #'),
                      TextField(
                        controller: _invoiceController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Inv Number', Icons.tag_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date Picker Row
            _fieldLabel('Transaction Date'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today_rounded, color: cyan, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Selector
            _fieldLabel('Category'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: cardColor,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                  items: CategoryService.standardCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Method
            _fieldLabel('Payment Method'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  dropdownColor: cardColor,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                  items: _paymentMethods.map((pm) {
                    return DropdownMenuItem<String>(
                      value: pm,
                      child: Text(pm, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPaymentMethod = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            _fieldLabel('Notes'),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Additional details', Icons.edit_note_rounded),
            ),

            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'SAVE TRANSACTION',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: cyan, size: 20),
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: purple, width: 1.5),
      ),
    );
  }
}
