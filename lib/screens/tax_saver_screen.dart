import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../services/financial_calculator_service.dart';

class TaxSaverScreen extends StatefulWidget {
  const TaxSaverScreen({super.key});

  @override
  State<TaxSaverScreen> createState() => _TaxSaverScreenState();
}

class _TaxSaverScreenState extends State<TaxSaverScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);
  static const Color orange = Color(0xFFFFB86B);

  late final TextEditingController _incomeController;
  late final TextEditingController _deduction80CController;
  late final TextEditingController _health80DController;
  late final TextEditingController _stdDeductionController;

  bool _isNewRegime = true;
  String _selectedYear = 'FY 2024-25 / 2025-26';
  String _selectedCountry = 'India';

  TaxCalculationResult? _result;

  @override
  void initState() {
    super.initState();
    final finance = context.read<FinanceProvider>();
    final annualIncome = (finance.monthlyIncome > 0 ? finance.monthlyIncome * 12 : finance.totalIncome * 12).clamp(300000.0, 10000000.0);

    _incomeController = TextEditingController(text: annualIncome.toStringAsFixed(0));
    _deduction80CController = TextEditingController(text: '150000');
    _health80DController = TextEditingController(text: '25000');
    _stdDeductionController = TextEditingController(text: '75000');

    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _deduction80CController.dispose();
    _health80DController.dispose();
    _stdDeductionController.dispose();
    super.dispose();
  }

  void _calculate() {
    final income = double.tryParse(_incomeController.text) ?? 1000000;
    final d80c = double.tryParse(_deduction80CController.text) ?? 0;
    final d80d = double.tryParse(_health80DController.text) ?? 0;
    final std = double.tryParse(_stdDeductionController.text) ?? 75000;

    setState(() {
      _result = FinancialCalculatorService.calculateTax(
        annualIncome: income,
        deduction80C: d80c,
        healthInsurance80D: d80d,
        standardDeduction: std,
        isNewRegime: _isNewRegime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Tax Saver Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Regime selector toggle
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isNewRegime = true;
                          _stdDeductionController.text = '75000';
                        });
                        _calculate();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isNewRegime ? purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'NEW REGIME',
                            style: TextStyle(
                              color: _isNewRegime ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isNewRegime = false;
                          _stdDeductionController.text = '50000';
                        });
                        _calculate();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isNewRegime ? purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'OLD REGIME',
                            style: TextStyle(
                              color: !_isNewRegime ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Metadata info
            Row(
              children: [
                Chip(
                  backgroundColor: cardColor,
                  label: Text('Country: $_selectedCountry', style: const TextStyle(color: cyan, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor: cardColor,
                  label: Text(_selectedYear, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Inputs
            _inputField('Gross Annual Income (₹)', _incomeController),

            const SizedBox(height: 14),

            if (!_isNewRegime) ...[
              _inputField('Section 80C Deductions (PPF, ELSS, EPF max 1.5L)', _deduction80CController),
              const SizedBox(height: 14),
              _inputField('Section 80D Health Insurance (max 25k/50k)', _health80DController),
              const SizedBox(height: 14),
            ],

            _inputField('Standard Deduction (₹)', _stdDeductionController),

            const SizedBox(height: 24),

            // Tax Summary Card
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cyan.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _result!.regimeName.toUpperCase(),
                          style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Effective: ${_result!.effectiveTaxRate.toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _summaryRow('Gross Income:', '₹${_result!.grossIncome.toStringAsFixed(0)}'),
                    _summaryRow('Eligible Deductions:', '-₹${_result!.totalDeductions.toStringAsFixed(0)}', color: green),
                    _summaryRow('Net Taxable Income:', '₹${_result!.taxableIncome.toStringAsFixed(0)}'),

                    const Divider(color: Colors.white12, height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Tax Liability:',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${_result!.estimatedTax.toStringAsFixed(0)}',
                          style: const TextStyle(color: red, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    if (_result!.taxSavingOpportunities.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'TAX SAVING OPPORTUNITIES',
                        style: TextStyle(color: orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      ..._result!.taxSavingOpportunities.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, color: green, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(tip, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            // Mandatory Educational Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.white38, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Educational estimate, not professional tax advice. Consult a certified chartered accountant for your tax returns.',
                      style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

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

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
