import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import 'dashboard_screen.dart';


class FinancialSetupScreen extends StatefulWidget {
  const FinancialSetupScreen({super.key});

  @override
  State<FinancialSetupScreen> createState() => _FinancialSetupScreenState();
}

class _FinancialSetupScreenState extends State<FinancialSetupScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF111C31);
  static const Color primaryPurple = Color(0xFF7C5CFC);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF35D07F);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _incomeController =
      TextEditingController();

  final TextEditingController _expenseController =
      TextEditingController();

  final TextEditingController _savingsController =
      TextEditingController();

  final TextEditingController _balanceController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String _selectedIncomeType = 'Monthly Salary';
  String _selectedFinancialGoal = 'Save More';

  bool _isLoading = false;

  final List<String> _incomeTypes = [
    'Monthly Salary',
    'Freelance',
    'Business',
    'Student',
    'Multiple Sources',
    'Other',
  ];

  final List<Map<String, dynamic>> _financialGoals = [
    {
      'title': 'Save More',
      'icon': Icons.savings_rounded,
      'color': Color(0xFF35D07F),
    },
    {
      'title': 'Invest',
      'icon': Icons.trending_up_rounded,
      'color': Color(0xFF4CC9F0),
    },
    {
      'title': 'Reduce Debt',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFFFF6B6B),
    },
    {
      'title': 'Track Spending',
      'icon': Icons.pie_chart_rounded,
      'color': Color(0xFFFFB347),
    },
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    _savingsController.dispose();
    _balanceController.dispose();
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
          _backgroundGlow(),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                40,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _topBar(),

                  const SizedBox(height: 28),

                  _heroSection(),

                  const SizedBox(height: 32),

                  _sectionTitle(
                    'Your Financial Snapshot',
                    'Help FinPilot understand your finances',
                  ),

                  const SizedBox(height: 18),

                  _financialInputCard(),

                  const SizedBox(height: 28),

                  _sectionTitle(
                    'Income Source',
                    'Where does most of your money come from?',
                  ),

                  const SizedBox(height: 16),

                  _incomeTypeSelector(),

                  const SizedBox(height: 30),

                  _sectionTitle(
                    'What is your main focus?',
                    'FinPilot will personalize your experience',
                  ),

                  const SizedBox(height: 16),

                  _goalSelector(),

                  const SizedBox(height: 35),

                  _continueButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Widget _backgroundGlow() {
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
                color: primaryPurple.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
          ),

          Positioned(
            top: 350,
            left: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Setup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Step 1 of your FinPilot journey',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: primaryPurple.withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'SETUP',
            style: TextStyle(
              color: primaryPurple,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _heroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            primaryPurple.withValues(alpha: 0.85),
            const Color(0xFF4030A0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(
              alpha: 0.20,
            ),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Let’s know your money',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'Your information helps FinPilot AI create smarter financial insights.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FINANCIAL INPUT CARD
  // ============================================================

  Widget _financialInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Column(
        children: [
          _moneyField(
            controller: _incomeController,
            label: 'Monthly Income',
            subtitle: 'How much do you earn?',
            icon: Icons.arrow_downward_rounded,
            color: green,
          ),

          const SizedBox(height: 18),

          _divider(),

          const SizedBox(height: 18),

          _moneyField(
            controller: _expenseController,
            label: 'Monthly Expenses',
            subtitle: 'Average monthly spending',
            icon: Icons.arrow_upward_rounded,
            color: Colors.redAccent,
          ),

          const SizedBox(height: 18),

          _divider(),

          const SizedBox(height: 18),

          _moneyField(
            controller: _savingsController,
            label: 'Current Savings',
            subtitle: 'Total money saved',
            icon: Icons.savings_rounded,
            color: cyan,
          ),

          const SizedBox(height: 18),

          _divider(),

          const SizedBox(height: 18),

          _moneyField(
            controller: _balanceController,
            label: 'Current Balance',
            subtitle: 'Money currently available',
            icon: Icons.account_balance_wallet_rounded,
            color: primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: Colors.white.withValues(
        alpha: 0.06,
      ),
    );
  }

  // ============================================================
  // MONEY FIELD
  // ============================================================

  Widget _moneyField({
    required TextEditingController controller,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: color,
            size: 23,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 115,
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '₹ 0',
              hintStyle: const TextStyle(
                color: Colors.white24,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INCOME TYPE SELECTOR
  // ============================================================

  Widget _incomeTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedIncomeType,
          dropdownColor: cardColor,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cyan,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          items: _incomeTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedIncomeType = value;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // GOAL SELECTOR
  // ============================================================

  Widget _goalSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _financialGoals.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = _financialGoals[index];

        final title = item['title'] as String;
        final icon = item['icon'] as IconData;
        final color = item['color'] as Color;

        final selected =
            _selectedFinancialGoal == title;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFinancialGoal = title;
            });
          },
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.14)
                  : cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.7)
                    : Colors.white.withValues(
                        alpha: 0.06,
                      ),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color:
                      selected ? color : Colors.white54,
                  size: 26,
                ),

                const SizedBox(height: 9),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white60,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
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
  // CONTINUE BUTTON
  // ============================================================

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _completeSetup,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: primaryPurple.withValues(
            alpha: 0.45,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue to Goals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // COMPLETE SETUP
  // ============================================================

  void _completeSetup() async {
    final income =
        double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;

    final expenses =
        double.tryParse(_expenseController.text.replaceAll(',', '')) ?? 0;

    final savings =
        double.tryParse(_savingsController.text.replaceAll(',', '')) ?? 0;

    final balance =
        double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;

    if (income <= 0) {
      _showMessage(
        'Please enter your monthly income',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Persist to FinanceProvider
    final finance = Provider.of<FinanceProvider>(context, listen: false);

    // Set starting balance (savings + current balance as the baseline)
    final startingBalance = savings + balance;
    await finance.updateStartingBalance(startingBalance);

    // Set monthly budget = income (user can refine in Budget screen later)
    await finance.updateMonthlyBudget(income);

    // Add a seed income transaction so the dashboard shows real income
    if (income > 0) {
      await finance.addIncome(
        title: '${_selectedIncomeType} Income',
        amount: income,
        category: _selectedIncomeType.contains('Salary') ? 'Salary' : 'Income',
        paymentMethod: 'Bank',
        note: 'Setup: estimated monthly $_selectedIncomeType income',
      );
    }

    // Add a seed expense transaction if the user entered monthly expenses
    if (expenses > 0) {
      await finance.addExpense(
        title: 'Monthly Living Expenses',
        amount: expenses,
        category: 'Bills',
        paymentMethod: 'Bank',
        note: 'Setup: estimated monthly expenses',
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }
}