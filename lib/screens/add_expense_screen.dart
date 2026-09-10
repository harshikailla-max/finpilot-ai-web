import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // ============================================================
  // THEME
  // ============================================================

  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color lightPurple = Color(0xFF9A8CFF);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);
  static const Color orange = Color(0xFFFFB86B);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _noteController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String _selectedCategory = 'Food';
  String _selectedPayment = 'UPI';

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  // ============================================================
  // DATA
  // ============================================================

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Travel',
    'Other',
  ];

  final List<String> _paymentMethods = [
    'UPI',
    'Cash',
    'Debit Card',
    'Credit Card',
    'Bank',
  ];

  final List<double> _quickAmounts = [
    100,
    500,
    1000,
    2000,
    5000,
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          _buildBackgroundGlow(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildExpenseHero(),

                        const SizedBox(height: 25),

                        _buildAmountSection(),

                        const SizedBox(height: 24),

                        _buildQuickAmounts(),

                        const SizedBox(height: 28),

                        _sectionTitle(
                          'EXPENSE DETAILS',
                          'Tell us where your money went',
                        ),

                        const SizedBox(height: 14),

                        _buildTitleField(),

                        const SizedBox(height: 16),

                        _buildCategorySelector(),

                        const SizedBox(height: 24),

                        _sectionTitle(
                          'PAYMENT METHOD',
                          'How did you pay?',
                        ),

                        const SizedBox(height: 14),

                        _buildPaymentMethods(),

                        const SizedBox(height: 24),

                        _sectionTitle(
                          'DATE',
                          'When did this expense happen?',
                        ),

                        const SizedBox(height: 14),

                        _buildDateSelector(),

                        const SizedBox(height: 24),

                        _sectionTitle(
                          'NOTE',
                          'Optional additional details',
                        ),

                        const SizedBox(height: 14),

                        _buildNoteField(),

                        const SizedBox(height: 24),

                        _buildBudgetInsight(finance),

                        const SizedBox(height: 30),

                        _buildSaveButton(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Widget _buildBackgroundGlow() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: red.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: -130,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withValues(alpha: 0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD TRANSACTION',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'New Expense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.remove_rounded,
              color: red,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildExpenseHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            red.withValues(alpha: 0.20),
            purple.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: red.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: red,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Track your spending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Every expense brings you closer to smarter financial decisions.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
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

  // ============================================================
  // AMOUNT SECTION
  // ============================================================

  Widget _buildAmountSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'EXPENSE AMOUNT',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  color: red,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 190,
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.white24,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK AMOUNTS
  // ============================================================

  Widget _buildQuickAmounts() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _quickAmounts.map((amount) {
        final isSelected =
            _amountController.text ==
                amount.toStringAsFixed(0);

        return GestureDetector(
          onTap: () {
            setState(() {
              _amountController.text =
                  amount.toStringAsFixed(0);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? red.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? red.withValues(alpha: 0.40)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: isSelected
                    ? red
                    : Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TITLE FIELD
  // ============================================================

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.edit_outlined,
            color: lightPurple,
          ),
          hintText: 'What did you spend on?',
          hintStyle: TextStyle(
            color: Colors.white30,
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY SELECTOR
  // ============================================================

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: _categories.map((category) {
        final selected =
            category == _selectedCategory;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? purple.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? purple.withValues(alpha: 0.50)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _categoryIcon(category),
                  color: selected
                      ? lightPurple
                      : Colors.white38,
                  size: 15,
                ),
                const SizedBox(width: 7),
                Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white54,
                    fontSize: 10,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // PAYMENT METHODS
  // ============================================================

  Widget _buildPaymentMethods() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _paymentMethods.map((method) {
        final selected =
            method == _selectedPayment;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPayment = method;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? cyan.withValues(alpha: 0.13)
                  : cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? cyan.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _paymentIcon(method),
                  size: 16,
                  color: selected
                      ? cyan
                      : Colors.white38,
                ),
                const SizedBox(width: 7),
                Text(
                  method,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // DATE SELECTOR
  // ============================================================

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: orange,
                size: 19,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Date',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFullDate(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTE FIELD
  // ============================================================

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 3,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        decoration: const InputDecoration(
          hintText: 'Add a note...',
          hintStyle: TextStyle(
            color: Colors.white30,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ============================================================
  // BUDGET INSIGHT
  // ============================================================

  Widget _buildBudgetInsight(
    FinanceProvider finance,
  ) {
    final spent = finance.totalExpense;
    final budget = finance.monthlyBudget;

    final percentage =
        finance.budgetPercentage.clamp(0.0, 1.0).toDouble();

    String message;
    Color insightColor;

    if (percentage >= 0.9) {
      message =
          'You are close to your monthly budget limit.';
      insightColor = red;
    } else if (percentage >= 0.7) {
      message =
          'You are approaching your monthly budget limit.';
      insightColor = orange;
    } else {
      message =
          'Your spending is currently within a healthy range.';
      insightColor = green;
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: insightColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: insightColor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: insightColor,
                size: 19,
              ),
              const SizedBox(width: 9),
              const Text(
                'FINPILOT AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            message,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 7,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.07),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                insightColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent ₹${_formatAmount(spent)}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                ),
              ),
              Text(
                'Budget ₹${_formatAmount(budget)}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _saveExpense,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: LinearGradient(
            colors: _isSaving
                ? [
                    Colors.grey.shade700,
                    Colors.grey.shade800,
                  ]
                : const [
                    Color(0xFFFF6B81),
                    Color(0xFFC73E57),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: red.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Save Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================
  // PICK DATE
  // ============================================================

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ============================================================
  // SAVE EXPENSE
  // ============================================================

  Future<void> _saveExpense() async {
    final title = _titleController.text.trim();

    final amount =
        double.tryParse(_amountController.text.trim());

    if (title.isEmpty) {
      _showMessage('Please enter an expense title.');
      return;
    }

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    context.read<FinanceProvider>().addExpense(
          title: title,
          amount: amount,
          category: _selectedCategory,
          paymentMethod: _selectedPayment,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    _showSuccessDialog(amount);
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withValues(alpha: 0.14),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: green,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Expense Added!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '₹${_formatAmount(amount)} has been added to your expenses.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: purple,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Back to Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;

      case 'transport':
        return Icons.directions_car_outlined;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'bills':
        return Icons.receipt_long_outlined;

      case 'entertainment':
        return Icons.movie_outlined;

      case 'health':
        return Icons.favorite_outline_rounded;

      case 'education':
        return Icons.school_outlined;

      case 'travel':
        return Icons.flight_takeoff_outlined;

      default:
        return Icons.category_outlined;
    }
  }

  // ============================================================
  // PAYMENT ICON
  // ============================================================

  IconData _paymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return Icons.qr_code_rounded;

      case 'cash':
        return Icons.payments_outlined;

      case 'debit card':
        return Icons.credit_card_outlined;

      case 'credit card':
        return Icons.credit_card_rounded;

      case 'bank':
        return Icons.account_balance_outlined;

      default:
        return Icons.payment_outlined;
    }
  }

  // ============================================================
  // FORMAT AMOUNT
  // ============================================================

  String _formatAmount(double amount) {
    return amount.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatFullDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}