import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../services/receipt_suggestion_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_financial_orb.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glass_card.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Uint8List? _receiptImageBytes;
  String? _receiptImageName;

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food & Dining';
  String _selectedPaymentMethod = 'UPI';

  bool _isSaved = false;
  Map<String, dynamic>? _analysisResult;
  FinanceTransaction? _savedTransaction;

  @override
  void initState() {
    super.initState();
    _merchantController.addListener(_onMerchantChanged);
  }

  @override
  void dispose() {
    _merchantController.removeListener(_onMerchantChanged);
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onMerchantChanged() {
    final text = _merchantController.text.trim();
    if (text.isNotEmpty) {
      final suggested = ReceiptSuggestionService.suggestCategory(text);
      if (suggested != 'Other' && mounted) {
        setState(() {
          _selectedCategory = suggested;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _receiptImageBytes = bytes;
        _receiptImageName = file.name;
        _isSaved = false;
        _analysisResult = null;
      });

      // If user hasn't typed merchant, try suggesting from filename if relevant
      if (_merchantController.text.isEmpty && file.name.isNotEmpty) {
        final cleanName = file.name.split('.').first.replaceAll(RegExp(r'[_\-]'), ' ');
        final suggested = ReceiptSuggestionService.suggestCategory(cleanName);
        if (suggested != 'Other') {
          setState(() {
            _selectedCategory = suggested;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.red,
          content: Text('Failed to load image: $e'),
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _receiptImageBytes = null;
      _receiptImageName = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.cyan,
              onPrimary: Colors.black,
              surface: Color(0xFF0F1528),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final merchant = _merchantController.text.trim();
    final notes = _notesController.text.trim();

    final finance = context.read<FinanceProvider>();

    final transaction = FinanceTransaction(
      id: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      title: merchant,
      amount: amount,
      type: 'expense',
      category: _selectedCategory,
      date: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      merchant: merchant,
      description: notes.isNotEmpty ? notes : 'Smart Receipt: $merchant',
      source: 'receipt',
      createdAt: DateTime.now(),
    );

    // Persist to real FinanceProvider
    await finance.addTransaction(transaction);

    // Compute real insight using current finance state
    final categorySpent = finance.expenseByCategory(_selectedCategory);
    final insight = ReceiptSuggestionService.generateInsight(
      merchant: merchant,
      amount: amount,
      category: _selectedCategory,
      categoryMonthTotal: categorySpent,
      monthlyBudget: finance.monthlyBudget,
      totalMonthlyExpenses: finance.monthlyExpenses,
    );

    if (mounted) {
      setState(() {
        _isSaved = true;
        _savedTransaction = transaction;
        _analysisResult = insight;
      });
    }
  }

  void _resetFormForNextReceipt() {
    setState(() {
      _merchantController.clear();
      _amountController.clear();
      _notesController.clear();
      _receiptImageBytes = null;
      _receiptImageName = null;
      _isSaved = false;
      _savedTransaction = null;
      _analysisResult = null;
      _selectedDate = DateTime.now();
      _selectedCategory = 'Food & Dining';
      _selectedPaymentMethod = 'UPI';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF060914).withValues(alpha: 0.85),
        elevation: 0,
        title: const Row(
          children: [
            AiFinancialOrb(size: 26),
            SizedBox(width: 10),
            Text(
              'Smart Receipt Expense',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Subtitle
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // If saved, display the luxury AI Insight Result Card
                    if (_isSaved && _analysisResult != null) ...[
                      _buildInsightResultCard(),
                      const SizedBox(height: 24),
                    ],

                    // Receipt Image Uploader & Preview
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Smart Receipt Form
                    _buildSmartForm(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF5FE1FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF5FE1FF).withValues(alpha: 0.3)),
              ),
              child: const Text(
                'AI COPILOT POWERED',
                style: TextStyle(
                  color: Color(0xFF5FE1FF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6CFF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'CROSS-PLATFORM',
                style: TextStyle(
                  color: Color(0xFF9E8CFF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Smart Receipt',
          style: TextStyle(
            color: Color(0xFFF5F7FB),
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Turn any receipt into a clean, verified expense with live budget telemetry.',
          style: TextStyle(
            color: Color(0xFF8E9BAE),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECEIPT IMAGE PREVIEW & UPLOADER
  // ============================================================
  Widget _buildImageSection() {
    if (_receiptImageBytes != null) {
      return GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(16),
        borderGradient: const LinearGradient(
          colors: [Color(0xFF5FE1FF), Color(0xFF7C6CFF)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF48D597), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _receiptImageName ?? 'Receipt Attached',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF48D597).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ READY TO RECORD',
                    style: TextStyle(
                      color: Color(0xFF48D597),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 280),
                width: double.infinity,
                color: Colors.black26,
                child: Image.memory(
                  _receiptImageBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('REPLACE IMAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5FE1FF),
                    side: const BorderSide(color: Color(0xFF5FE1FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFFF667F)),
                  label: const Text('REMOVE', style: TextStyle(color: Color(0xFFFF667F), fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Empty State Card
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5FE1FF).withValues(alpha: 0.2),
                  const Color(0xFF7C6CFF).withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(color: const Color(0xFF5FE1FF).withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF5FE1FF), size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Capture your spending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload or photograph a receipt to confirm your numbers with instant budget intelligence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8E9BAE),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('UPLOAD RECEIPT', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                label: const Text('CAMERA', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5FE1FF),
                  side: const BorderSide(color: Color(0xFF5FE1FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMART RECEIPT FORM
  // ============================================================
  Widget _buildSmartForm() {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(22),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: Color(0xFF5FE1FF), size: 20),
                SizedBox(width: 8),
                Text(
                  'EXPENSE DETAILS',
                  style: TextStyle(
                    color: Color(0xFF5FE1FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Merchant Field
            _buildFieldLabel('MERCHANT / STORE NAME'),
            TextFormField(
              controller: _merchantController,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              decoration: _buildInputDecoration(
                hint: 'e.g. Starbucks, Swiggy, Amazon, Uber...',
                icon: Icons.storefront_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter merchant name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount Field
            _buildFieldLabel('AMOUNT (₹)'),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: Color(0xFF5FE1FF),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              decoration: _buildInputDecoration(
                hint: '0.00',
                icon: Icons.currency_rupee_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter amount';
                }
                final num = double.tryParse(value.trim());
                if (num == null || num <= 0) {
                  return 'Enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category & Payment Method Row
            Row(
              children: [
                // Category Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('CATEGORY'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: const Color(0xFF0F1528),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: _buildInputDecoration(hint: 'Category', icon: Icons.category_rounded),
                        items: ReceiptSuggestionService.standardCategories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Payment Method Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('PAYMENT METHOD'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPaymentMethod,
                        dropdownColor: const Color(0xFF0F1528),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: _buildInputDecoration(hint: 'Method', icon: Icons.payment_rounded),
                        items: ReceiptSuggestionService.paymentMethods.map((m) {
                          return DropdownMenuItem(value: m, child: Text(m));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPaymentMethod = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Picker Field
            _buildFieldLabel('TRANSACTION DATE'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1020),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Color(0xFF5FE1FF), size: 18),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd MMMM yyyy').format(_selectedDate),
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const Text(
                      'CHANGE',
                      style: TextStyle(color: Color(0xFF5FE1FF), fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Optional Notes
            _buildFieldLabel('NOTES (OPTIONAL)'),
            TextFormField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _buildInputDecoration(
                hint: 'Tax invoice #, personal tag, or reason...',
                icon: Icons.notes_rounded,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitExpense,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text(
                  'CONFIRM & ADD EXPENSE',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48D597),
                  foregroundColor: const Color(0xFF05070D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AI-STYLE FINANCIAL INSIGHT RESULT CARD
  // ============================================================
  Widget _buildInsightResultCard() {
    final result = _analysisResult!;
    final impact = result['budgetImpact'] as Map<String, dynamic>;
    final tx = _savedTransaction!;

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(22),
      borderGradient: const LinearGradient(
        colors: [Color(0xFF48D597), Color(0xFF5FE1FF), Color(0xFF7C6CFF)],
      ),
      shadows: [
        BoxShadow(
          color: const Color(0xFF48D597).withValues(alpha: 0.15),
          blurRadius: 36,
          spreadRadius: 2,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF48D597).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.done_all_rounded, color: Color(0xFF48D597), size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'RECEIPT ANALYZED ✓',
                    style: TextStyle(
                      color: Color(0xFF48D597),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _resetFormForNextReceipt,
                child: const Text(
                  '+ ADD ANOTHER',
                  style: TextStyle(color: Color(0xFF5FE1FF), fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary amount & merchant display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${tx.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tx.merchant ?? tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB8C0D0),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${tx.category} • ${tx.paymentMethod}',
              style: const TextStyle(color: Color(0xFF5FE1FF), fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),

          // Budget Impact Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Budget Impact', style: TextStyle(color: Color(0xFF8E9BAE), fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(
                    '₹${(impact['newTotalExpense'] as double).round()} / ₹${(impact['monthlyBudget'] as double).round()}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (impact['percentage'] as double).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    (impact['isOverBudget'] as bool) ? const Color(0xFFFF667F) : const Color(0xFF5FE1FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // AI Insight Commentary Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF090E1D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C6CFF).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C6CFF), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      result['headline'] as String,
                      style: const TextStyle(
                        color: Color(0xFF9E8CFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result['insight'] as String,
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12.5, height: 1.45),
                ),
                const SizedBox(height: 10),
                Text(
                  '💡 Recommendation: ${result['recommendation']}',
                  style: const TextStyle(
                    color: Color(0xFF48D597),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF737D91),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 12.5),
      prefixIcon: Icon(icon, color: const Color(0xFF5FE1FF), size: 18),
      filled: true,
      fillColor: const Color(0xFF0B1020),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF5FE1FF), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF667F), width: 1.2),
      ),
    );
  }
}
