import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

class SavingsPlannerScreen extends StatefulWidget {
  const SavingsPlannerScreen({super.key});

  @override
  State<SavingsPlannerScreen> createState() => _SavingsPlannerScreenState();
}

class _SavingsPlannerScreenState extends State<SavingsPlannerScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color orange = Color(0xFFFFB86B);

  double _emergencyPct = 30.0;
  double _goalsPct = 40.0;
  double _investPct = 30.0;

  // What-if simulator delta sliders
  double _simIncomeDelta = 0.0;
  double _simExpenseDelta = 0.0;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final baseIncome = finance.monthlyIncome > 0 ? finance.monthlyIncome : finance.totalIncome;
    final baseExpenses = finance.monthlyExpenses > 0 ? finance.monthlyExpenses : finance.totalExpense;

    final simIncome = math.max(0.0, baseIncome + _simIncomeDelta);
    final simExpenses = math.max(0.0, baseExpenses + _simExpenseDelta);
    final totalCapacity = math.max(0.0, simIncome - simExpenses);

    final emergencyAmount = totalCapacity * (_emergencyPct / 100);
    final goalsAmount = totalCapacity * (_goalsPct / 100);
    final investAmount = totalCapacity * (_investPct / 100);

    // Emergency fund requirements (3, 6, 9 months)
    final ef3 = simExpenses * 3;
    final ef6 = simExpenses * 6;
    final ef9 = simExpenses * 9;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Savings Planner & Simulator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Capacity Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACTUAL MONTHLY SAVINGS CAPACITY', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('₹${totalCapacity.toStringAsFixed(0)} / month', style: const TextStyle(color: green, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Simulated Income: ₹${simIncome.toStringAsFixed(0)} • Simulated Expenses: ₹${simExpenses.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Distribution Allocations
            const Text('SAVINGS ALLOCATION (% of Available Capacity)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            _allocationCard(
              title: 'Emergency Safety Buffer',
              subtitle: 'Liquid cash / bank balance',
              pct: _emergencyPct,
              amount: emergencyAmount,
              color: cyan,
              onChanged: (val) {
                setState(() {
                  _emergencyPct = val;
                  final remaining = 100 - _emergencyPct;
                  _goalsPct = (remaining * 0.55).clamp(0, 100);
                  _investPct = math.max(0.0, 100 - _emergencyPct - _goalsPct);
                });
              },
            ),

            const SizedBox(height: 10),

            _allocationCard(
              title: 'Goal Milestones',
              subtitle: 'Vacation, gadgets, car down payment',
              pct: _goalsPct,
              amount: goalsAmount,
              color: purple,
              onChanged: (val) {
                setState(() {
                  _goalsPct = val;
                  final remaining = 100 - _goalsPct;
                  _emergencyPct = (remaining * 0.5).clamp(0, 100);
                  _investPct = math.max(0.0, 100 - _goalsPct - _emergencyPct);
                });
              },
            ),

            const SizedBox(height: 10),

            _allocationCard(
              title: 'Long-term Wealth / SIP',
              subtitle: 'Mutual funds, index equity',
              pct: _investPct,
              amount: investAmount,
              color: green,
              onChanged: (val) {
                setState(() {
                  _investPct = val;
                  final remaining = 100 - _investPct;
                  _emergencyPct = (remaining * 0.5).clamp(0, 100);
                  _goalsPct = math.max(0.0, 100 - _investPct - _emergencyPct);
                });
              },
            ),

            const SizedBox(height: 28),

            // Section 35: Emergency Fund Check
            const Text('EMERGENCY FUND BENCHMARKS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _efRow('3 Months (Basic Safety):', '₹${ef3.toStringAsFixed(0)}', finance.balance >= ef3),
                  const Divider(color: Colors.white10, height: 16),
                  _efRow('6 Months (Recommended):', '₹${ef6.toStringAsFixed(0)}', finance.balance >= ef6),
                  const Divider(color: Colors.white10, height: 16),
                  _efRow('9 Months (Robust Fortress):', '₹${ef9.toStringAsFixed(0)}', finance.balance >= ef9),
                  const SizedBox(height: 10),
                  Text(
                    'Your current available balance is ₹${finance.balance.toStringAsFixed(0)}.',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 34: What-if Simulator Sliders
            const Text('WHAT-IF SIMULATOR', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            Container(
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
                      const Text('Change Income:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('${_simIncomeDelta >= 0 ? "+" : ""}₹${_simIncomeDelta.toStringAsFixed(0)}', style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Slider(
                    value: _simIncomeDelta,
                    min: -20000,
                    max: 50000,
                    divisions: 14,
                    activeColor: green,
                    onChanged: (val) => setState(() => _simIncomeDelta = val),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Change Expenses:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('${_simExpenseDelta >= 0 ? "+" : ""}₹${_simExpenseDelta.toStringAsFixed(0)}', style: const TextStyle(color: orange, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Slider(
                    value: _simExpenseDelta,
                    min: -15000,
                    max: 30000,
                    divisions: 9,
                    activeColor: orange,
                    onChanged: (val) => setState(() => _simExpenseDelta = val),
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

  Widget _allocationCard({
    required String title,
    required String subtitle,
    required double pct,
    required double amount,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${amount.toStringAsFixed(0)}/mo', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ],
          ),
          Slider(
            value: pct,
            min: 0,
            max: 100,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _efRow(String label, String amount, bool achieved) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Row(
          children: [
            Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 8),
            Icon(
              achieved ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: achieved ? green : Colors.white24,
              size: 16,
            ),
          ],
        ),
      ],
    );
  }
}
