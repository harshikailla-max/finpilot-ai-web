import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../services/financial_calculator_service.dart';

class MoneyLeakScreen extends StatelessWidget {
  const MoneyLeakScreen({super.key});

  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);
  static const Color orange = Color(0xFFFFB86B);

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final leaks = FinancialCalculatorService.detectMoneyLeaks(finance.transactions);
    final totalPotentialSaving = leaks.fold<double>(0, (sum, l) => sum + l.potentialMonthlySaving);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Money Leak Detector', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2C194D), Color(0xFF121A30)]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: purple.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.search_rounded, color: cyan),
                      SizedBox(width: 10),
                      Text(
                        'AI SPENDING AUDIT',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '₹${totalPotentialSaving.toStringAsFixed(0)} / month',
                    style: const TextStyle(color: green, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Identified potential monthly savings across your actual transactions without sacrificing lifestyle.',
                    style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'DETECTED SPENDING PATTERNS',
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
            ),

            const SizedBox(height: 14),

            if (leaks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Center(
                  child: Text(
                    'Great job! No significant spending leaks detected in your current transaction history.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
              )
            else
              ...leaks.map((leak) => _leakCard(leak)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _leakCard(MoneyLeakItem leak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leak.category,
                style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Save ₹${leak.potentialMonthlySaving.toStringAsFixed(0)}/mo',
                  style: const TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            leak.title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Actual spending: ₹${leak.monthlySpending.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Text(
                '(${leak.frequency} transactions)',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates_outlined, color: orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leak.tip,
                    style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
