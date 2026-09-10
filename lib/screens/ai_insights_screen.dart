import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../services/financial_calculator_service.dart';
import 'car_affordability_screen.dart';
import 'savings_planner_screen.dart';
import 'tax_saver_screen.dart';
import 'money_leak_screen.dart';
import 'subscription_screen.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color orange = Color(0xFFFFB86B);
  static const Color red = Color(0xFFFF6B6B);

  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final List<String> _quickQuestions = [
    'Can I buy a car in one year?',
    'How much should I save every month?',
    'Where am I spending too much?',
    'How much can I invest?',
    'Can I afford a ₹20,000 phone?',
    'How much do I need for an emergency fund?',
    'How much am I spending on food?',
    'How much can I save if I reduce shopping by 20%?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'ai',
      'text':
          'Hello! I am FinPilot, your AI Financial Copilot. Ask me about your real affordability, budget optimization, emergency buffers, or choose from the quick inquiries below.',
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _askCopilot(String question) {
    if (question.trim().isEmpty) return;

    final finance = context.read<FinanceProvider>();
    setState(() {
      _messages.add({'sender': 'user', 'text': question});
    });

    _queryController.clear();

    final income = finance.monthlyIncome > 0 ? finance.monthlyIncome : finance.totalIncome;
    final expenses = finance.monthlyExpenses > 0 ? finance.monthlyExpenses : finance.totalExpense;

    final answer = FinancialCalculatorService.answerCopilotQuery(
      question: question,
      monthlyIncome: income,
      monthlyExpenses: expenses,
      currentBalance: finance.balance,
      transactions: finance.transactions,
      goals: finance.goals,
    );

    setState(() {
      _messages.add({'sender': 'ai', 'text': answer});
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final health = finance.financialHealth;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('AI Financial Copilot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Health Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF281845), Color(0xFF10192B)]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: purple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: cyan, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Health: ${health['score']}/100 (${health['label']})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monthly Capacity: ₹${finance.monthlySavings.toStringAsFixed(0)} • Balance: ₹${finance.balance.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Deep Dive Financial Tools Row
            const Text(
              'SPECIALIZED AI TOOLS',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _toolButton(
                    'Car Affordability',
                    Icons.directions_car_rounded,
                    cyan,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CarAffordabilityScreen())),
                  ),
                  _toolButton(
                    'Savings Planner',
                    Icons.savings_rounded,
                    green,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPlannerScreen())),
                  ),
                  _toolButton(
                    'Tax Saver Mode',
                    Icons.account_balance_rounded,
                    orange,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxSaverScreen())),
                  ),
                  _toolButton(
                    'Money Leaks',
                    Icons.search_rounded,
                    red,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoneyLeakScreen())),
                  ),
                  _toolButton(
                    'Subscriptions',
                    Icons.subscriptions_rounded,
                    purple,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Quick Question Prompts
            const Text(
              'ASK AI COPILOT',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickQuestions.map((q) {
                return ActionChip(
                  backgroundColor: cardColor,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  label: Text(q, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  onPressed: () => _askCopilot(q),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Conversation Chat History
            ..._messages.map((m) {
              final isUser = m['sender'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                  decoration: BoxDecoration(
                    color: isUser ? purple.withValues(alpha: 0.25) : cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isUser ? purple.withValues(alpha: 0.4) : Colors.white10,
                    ),
                  ),
                  child: Text(
                    m['text'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Input Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask FinPilot anything about your finances...',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.white10)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.white10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: purple)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: _askCopilot,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _askCopilot(_queryController.text),
                  icon: const Icon(Icons.send_rounded, color: cyan),
                  style: IconButton.styleFrom(backgroundColor: cardColor, padding: const EdgeInsets.all(12)),
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}