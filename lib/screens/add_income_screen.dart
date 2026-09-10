import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  // ============================================================
  // THEME
  // ============================================================

  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color lightPurple = Color(0xFF9A8CFF);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _sourceController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _noteController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String _selectedCategory = 'Salary';
  String _selectedReceivedThrough = 'Bank';
  String _selectedRecurring = 'Monthly';
  String _selectedIncomeType = 'Recurring';

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  // ============================================================
  // OPTIONS
  // ============================================================

  final List<String> _categories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Bonus',
    'Gift',
    'Scholarship',
    'Other',
  ];

  final List<String> _paymentMethods = [
    'Bank',
    'UPI',
    'Cash',
    'PayPal',
    'Other',
  ];

  final List<String> _recurringOptions = [
    'Never',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  final List<String> _incomeTypes = [
    'One Time',
    'Recurring',
  ];

  final List<double> _quickAmounts = [
    1000,
    5000,
    10000,
    25000,
    50000,
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: Stack(
        children: [
          _buildBackgroundGlow(),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),

                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      120,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        _buildHeroCard(),

                        const SizedBox(height: 25),

                        _sectionTitle(
                          'INCOME DETAILS',
                          'Tell us about your earnings',
                        ),

                        const SizedBox(height: 14),

                        _buildSourceField(),

                        const SizedBox(height: 16),

                        _buildAmountField(),

                        const SizedBox(height: 18),

                        _buildQuickAmounts(),

                        const SizedBox(height: 28),

                        _sectionTitle(
                          'CATEGORY',
                          'Select your income source',
                        ),

                        const SizedBox(height: 14),

                        _buildCategoryGrid(),

                        const SizedBox(height: 28),

                        _sectionTitle(
                          'RECEIVED THROUGH',
                          'Choose payment method',
                        ),

                        const SizedBox(height: 14),

                        _buildPaymentMethods(),

                        const SizedBox(height: 28),

                        _sectionTitle(
                          'INCOME SETTINGS',
                          'Customize income details',
                        ),

                        const SizedBox(height: 14),

                        _buildIncomeTypeSelector(),

                        const SizedBox(height: 14),

                        _buildRecurringSelector(),

                        const SizedBox(height: 20),

                        _buildDateSelector(),

                        const SizedBox(height: 28),

                        _sectionTitle(
                          'NOTES',
                          'Optional information',
                        ),

                        const SizedBox(height: 14),

                        _buildNotesField(),

                        const SizedBox(height: 30),

                        _buildIncomePreview(),

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
            top: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: green.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            left: -120,
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
  // APP BAR
  // ============================================================

  Widget _buildAppBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },

            child: Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color:
                    Colors.white.withValues(alpha: 0.05),

                borderRadius:
                    BorderRadius.circular(15),

                border: Border.all(
                  color:
                      Colors.white.withValues(alpha: 0.08),
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
                  'ADD INCOME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Track your earnings',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.add_circle_outline_rounded,
              color: green,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(25),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            green.withValues(alpha: 0.22),
            cyan.withValues(alpha: 0.08),
            purple.withValues(alpha: 0.08),
          ],
        ),

        border: Border.all(
          color: green.withValues(alpha: 0.20),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                colors: [
                  green,
                  cyan,
                ],
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      green.withValues(alpha: 0.25),

                  blurRadius: 20,
                ),
              ],
            ),

            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Grow Your Financial Future',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Every income you track helps FinPilot understand your financial journey better.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    height: 1.5,
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

        const SizedBox(height: 5),

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
  // SOURCE FIELD
  // ============================================================

  Widget _buildSourceField() {
    return TextField(
      controller: _sourceController,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: _inputDecoration(
        hint: 'Income source',
        icon: Icons.person_outline_rounded,
      ),
    );
  }

  // ============================================================
  // AMOUNT FIELD
  // ============================================================

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,

      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),

      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),

      decoration: _inputDecoration(
        hint: '0.00',
        icon: Icons.currency_rupee_rounded,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Colors.white24,
      ),

      prefixIcon: Icon(
        icon,
        color: lightPurple,
      ),

      filled: true,

      fillColor:
          Colors.white.withValues(alpha: 0.045),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),

        borderSide: BorderSide(
          color:
              Colors.white.withValues(alpha: 0.08),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),

        borderSide: BorderSide(
          color:
              Colors.white.withValues(alpha: 0.08),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),

        borderSide: const BorderSide(
          color: green,
          width: 1.4,
        ),
      ),
    );
  }

  // ============================================================
  // QUICK AMOUNTS
  // ============================================================

  Widget _buildQuickAmounts() {
    return Wrap(
      spacing: 9,
      runSpacing: 9,

      children: _quickAmounts.map((amount) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _amountController.text =
                  amount.toStringAsFixed(0);
            });
          },

          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 9,
            ),

            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.04),

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color:
                    Colors.white.withValues(alpha: 0.07),
              ),
            ),

            child: Text(
              '₹${_formatAmount(amount)}',

              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // CATEGORY GRID
  // ============================================================

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,

      children: _categories.map((category) {
        final selected =
            _selectedCategory == category;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },

          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 200),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),

            decoration: BoxDecoration(
              color: selected
                  ? green.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.04),

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color: selected
                    ? green.withValues(alpha: 0.60)
                    : Colors.white.withValues(alpha: 0.07),
              ),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Icon(
                  _categoryIcon(category),

                  color: selected
                      ? green
                      : Colors.white38,

                  size: 16,
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

      children:
          _paymentMethods.map((method) {
        final selected =
            _selectedReceivedThrough == method;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedReceivedThrough = method;
            });
          },

          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),

            decoration: BoxDecoration(
              color: selected
                  ? cyan.withValues(alpha: 0.13)
                  : Colors.white.withValues(alpha: 0.04),

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color: selected
                    ? cyan.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.07),
              ),
            ),

            child: Text(
              method,

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
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // INCOME TYPE
  // ============================================================

  Widget _buildIncomeTypeSelector() {
    return _buildSelectorCard(
      title: 'Income Type',
      value: _selectedIncomeType,
      icon: Icons.category_outlined,

      onTap: () {
        _showOptionsSheet(
          title: 'Select Income Type',
          options: _incomeTypes,
          selectedValue: _selectedIncomeType,

          onSelected: (value) {
            setState(() {
              _selectedIncomeType = value;
            });
          },
        );
      },
    );
  }

  // ============================================================
  // RECURRING
  // ============================================================

  Widget _buildRecurringSelector() {
    return _buildSelectorCard(
      title: 'Frequency',
      value: _selectedRecurring,
      icon: Icons.repeat_rounded,

      onTap: () {
        _showOptionsSheet(
          title: 'Select Frequency',
          options: _recurringOptions,
          selectedValue: _selectedRecurring,

          onSelected: (value) {
            setState(() {
              _selectedRecurring = value;
            });
          },
        );
      },
    );
  }

  // ============================================================
  // SELECTOR CARD
  // ============================================================

  Widget _buildSelectorCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(17),

        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: 0.045),

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color:
                Colors.white.withValues(alpha: 0.07),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                color:
                    purple.withValues(alpha: 0.12),

                borderRadius:
                    BorderRadius.circular(13),
              ),

              child: Icon(
                icon,
                color: lightPurple,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,

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
  // DATE SELECTOR
  // ============================================================

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,

      child: Container(
        padding: const EdgeInsets.all(17),

        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: 0.045),

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color:
                Colors.white.withValues(alpha: 0.07),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                color:
                    cyan.withValues(alpha: 0.12),

                borderRadius:
                    BorderRadius.circular(13),
              ),

              child: const Icon(
                Icons.calendar_today_outlined,
                color: cyan,
                size: 18,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    'RECEIVED DATE',

                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      letterSpacing: 0.7,
                    ),
                  ),

                  const SizedBox(height: 5),

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
              Icons.arrow_forward_ios_rounded,
              color: Colors.white30,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  Widget _buildNotesField() {
    return TextField(
      controller: _noteController,

      maxLines: 4,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: _inputDecoration(
        hint: 'Add a note about this income...',
        icon: Icons.notes_rounded,
      ),
    );
  }

  // ============================================================
  // INCOME PREVIEW
  // ============================================================

  Widget _buildIncomePreview() {
    final amount =
        double.tryParse(_amountController.text) ??
            0;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),

        gradient: LinearGradient(
          colors: [
            green.withValues(alpha: 0.14),
            cyan.withValues(alpha: 0.05),
          ],
        ),

        border: Border.all(
          color:
              green.withValues(alpha: 0.20),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: cyan,
                size: 17,
              ),

              SizedBox(width: 8),

              Text(
                'FINPILOT PREVIEW',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Income Amount',

                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),

              Text(
                '+₹${_formatAmount(amount)}',

                style: const TextStyle(
                  color: green,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            height: 1,
            color:
                Colors.white.withValues(alpha: 0.08),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              _previewItem(
                'Category',
                _selectedCategory,
              ),

              _previewItem(
                'Method',
                _selectedReceivedThrough,
                alignRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewItem(
    String label,
    String value, {
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,

      child: ElevatedButton(
        onPressed:
            _isSaving ? null : _saveIncome,

        style: ElevatedButton.styleFrom(
          backgroundColor: green,

          disabledBackgroundColor:
              green.withValues(alpha: 0.40),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),

        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,

                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                  ),

                  SizedBox(width: 10),

                  Text(
                    'SAVE INCOME',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // SAVE INCOME
  // ============================================================

  Future<void> _saveIncome() async {
    final source =
        _sourceController.text.trim();

    final amount =
        double.tryParse(_amountController.text);

    if (source.isEmpty) {
      _showMessage(
        'Please enter an income source.',
        isError: true,
      );
      return;
    }

    if (amount == null || amount <= 0) {
      _showMessage(
        'Please enter a valid amount.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final transaction = TransactionModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        title: source,

        amount: amount,

        category: _selectedCategory,

        paymentMethod:
            _selectedReceivedThrough,

        date: _selectedDate,

        type: 'income',

        description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),

        source: 'manual',
      );

      context
          .read<FinanceProvider>()
          .addTransaction(transaction);

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      _showMessage(
        'Income added successfully!',
      );

      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final selected =
        await showDatePicker(
      context: context,

      initialDate: _selectedDate,

      firstDate:
          DateTime(DateTime.now().year - 5),

      lastDate:
          DateTime(DateTime.now().year + 5),

      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: purple,
              secondary: cyan,
              surface: cardColor,
            ),
          ),

          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  // ============================================================
  // OPTIONS SHEET
  // ============================================================

  void _showOptionsSheet({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,

      backgroundColor: cardColor,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              15,
              20,
              30,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 45,
                  height: 4,

                  decoration: BoxDecoration(
                    color: Colors.white24,

                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  title,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 20),

                ...options.map((option) {
                  final selected =
                      option == selectedValue;

                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },

                    child: Container(
                      width: double.infinity,

                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      padding:
                          const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: selected
                            ? green.withValues(
                                alpha: 0.10,
                              )
                            : Colors.white
                                .withValues(
                                alpha: 0.04,
                              ),

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),

                        border: Border.all(
                          color: selected
                              ? green.withValues(
                                  alpha: 0.50,
                                )
                              : Colors.white
                                  .withValues(
                                  alpha: 0.06,
                                ),
                        ),
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,

                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.white60,

                                fontSize: 13,

                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),

                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: green,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
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

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()

      ..showSnackBar(
        SnackBar(
          content: Text(message),

          backgroundColor:
              isError ? Colors.redAccent : green,

          behavior:
              SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _categoryIcon(
    String category,
  ) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.account_balance_outlined;

      case 'freelance':
        return Icons.laptop_mac_outlined;

      case 'business':
        return Icons.business_center_outlined;

      case 'investment':
        return Icons.trending_up_rounded;

      case 'bonus':
        return Icons.card_giftcard_outlined;

      case 'gift':
        return Icons.redeem_outlined;

      case 'scholarship':
        return Icons.school_outlined;

      default:
        return Icons.payments_outlined;
    }
  }

  // ============================================================
  // FORMAT AMOUNT
  // ============================================================

  String _formatAmount(double amount) {
    return amount
        .round()
        .toString()
        .replaceAllMapped(
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