import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../services/financial_calculator_service.dart';

class CarAffordabilityScreen extends StatefulWidget {
  const CarAffordabilityScreen({super.key});

  @override
  State<CarAffordabilityScreen> createState() => _CarAffordabilityScreenState();
}

class _CarAffordabilityScreenState extends State<CarAffordabilityScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color orange = Color(0xFFFFB86B);

  late final TextEditingController _carPriceController;
  late final TextEditingController _savingsController;
  late final TextEditingController _monthsController;
  late final TextEditingController _downPaymentPctController;
  late final TextEditingController _interestRateController;
  late final TextEditingController _tenureYearsController;

  CarAffordabilityResult? _result;

  @override
  void initState() {
    super.initState();
    final finance = context.read<FinanceProvider>();
    _carPriceController = TextEditingController(text: '1000000');
    _savingsController = TextEditingController(text: finance.balance > 0 ? finance.balance.toStringAsFixed(0) : '200000');
    _monthsController = TextEditingController(text: '12');
    _downPaymentPctController = TextEditingController(text: '20');
    _interestRateController = TextEditingController(text: '9.5');
    _tenureYearsController = TextEditingController(text: '5');

    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

  @override
  void dispose() {
    _carPriceController.dispose();
    _savingsController.dispose();
    _monthsController.dispose();
    _downPaymentPctController.dispose();
    _interestRateController.dispose();
    _tenureYearsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final finance = context.read<FinanceProvider>();
    final price = double.tryParse(_carPriceController.text) ?? 1000000;
    final savings = double.tryParse(_savingsController.text) ?? finance.balance;
    final months = int.tryParse(_monthsController.text) ?? 12;
    final dpPct = double.tryParse(_downPaymentPctController.text) ?? 20;
    final interest = double.tryParse(_interestRateController.text) ?? 9.5;
    final years = int.tryParse(_tenureYearsController.text) ?? 5;

    final income = finance.monthlyIncome > 0 ? finance.monthlyIncome : finance.totalIncome;
    final expenses = finance.monthlyExpenses > 0 ? finance.monthlyExpenses : finance.totalExpense;

    setState(() {
      _result = FinancialCalculatorService.calculateCarAffordability(
        carPrice: price,
        currentSavings: savings,
        targetMonths: months,
        downPaymentPercentage: dpPct,
        annualInterestRate: interest,
        loanTenureYears: years,
        monthlyIncome: income > 0 ? income : 65000,
        monthlyExpenses: expenses > 0 ? expenses : 25000,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final currentSurplus = finance.monthlySavings > 0 ? finance.monthlySavings : (finance.totalIncome - finance.totalExpense);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Car Affordability', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live financial context banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded, color: cyan, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Real Monthly Savings Capacity: ₹${currentSurplus.toStringAsFixed(0)}/month\nAvailable Balance: ₹${finance.balance.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Inputs
            _inputField('Car Price (₹)', _carPriceController),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _inputField('Current Savings (₹)', _savingsController)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Timeline (Months)', _monthsController)),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _inputField('Down Payment (%)', _downPaymentPctController)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Loan Rate (%/yr)', _interestRateController)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Tenure (Yrs)', _tenureYearsController)),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('RECALCULATE AFFORDABILITY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 28),

            // Result Card
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _result!.isFeasible ? green.withValues(alpha: 0.4) : orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AFFORDABILITY SCORE',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_result!.isFeasible ? green : orange).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_result!.affordabilityScore} / 100',
                            style: TextStyle(color: _result!.isFeasible ? green : orange, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _metricRow('Required Down Payment:', '₹${_result!.downPayment.toStringAsFixed(0)}'),
                    _metricRow('Monthly Savings to Goal:', '₹${_result!.monthlySavingsRequired.toStringAsFixed(0)}/mo', highlightColor: cyan),
                    _metricRow('Your Monthly Capacity:', '₹${currentSurplus.toStringAsFixed(0)}/mo'),
                    _metricRow('Estimated EMI (5 yrs):', '₹${_result!.estimatedEmi.toStringAsFixed(0)}/mo'),
                    _metricRow('Debt-To-Income (DTI):', '${_result!.debtToIncomeRatio.toStringAsFixed(1)}%'),

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 10),

                    Text(
                      _result!.recommendation,
                      style: TextStyle(
                        color: _result!.isFeasible ? Colors.white70 : orange,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: purple)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (_) => _calculate(),
        ),
      ],
    );
  }

  Widget _metricRow(String label, String value, {Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(
            value,
            style: TextStyle(color: highlightColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
