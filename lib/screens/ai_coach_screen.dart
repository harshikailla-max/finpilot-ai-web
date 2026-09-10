import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_financial_orb.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glass_card.dart';
import '../services/ai_financial_coach_service.dart';

import 'goal_screen.dart';
import 'investment_screen.dart';
import 'budget_screen.dart';
import 'car_affordability_screen.dart';
import 'savings_planner_screen.dart';
import 'receipt_scanner_screen.dart';
import 'money_leak_screen.dart';
import 'tax_saver_screen.dart';
import 'subscription_screen.dart';
import 'bank_statement_import_screen.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> actionTypes;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionTypes = const [],
  });
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  final List<String> _defaultSuggestions = [
    'Can I afford a ₹80,000 laptop?',
    'Can I afford a car next year?',
    'Where should I invest my money?',
    'How much should I save every month?',
    'How much do I need for my emergency fund?',
    'Where is most of my money going?',
    'What happens if I save ₹10,000/month?',
    'Create a monthly budget for me',
    'Should I pay my debt first or invest?',
    'Check my financial health',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text:
            'Hello! I am FinPilot, your Personal AI Financial Copilot.\n\n'
            'I analyze your real cash flow, spending patterns, and goals to provide bespoke financial intelligence. Ask me about your purchase affordability, monthly budgets, investment asset allocations, or choose a suggestion below.',
        isUser: false,
        timestamp: DateTime.now(),
        actionTypes: ['open_investment', 'open_goal'],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserQuery(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isThinking = true;
    });
    _scrollToBottom();

    // Subtle processing delay for premium feel
    await Future.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    final finance = context.read<FinanceProvider>();
    final goals = context.read<GoalProvider>().goals;
    final budgets = context.read<BudgetProvider>().budgets;

    final response = AiFinancialCoachService.processQuery(
      question: text,
      currentBalance: finance.balance,
      monthlyIncome: finance.monthlyIncome > 0 ? finance.monthlyIncome : finance.totalIncome,
      monthlyExpenses: finance.monthlyExpenses > 0 ? finance.monthlyExpenses : finance.totalExpense,
      transactions: finance.transactions,
      goals: goals,
      budgets: budgets,
      investments: finance.investments,
      financialHealthScore: (finance.financialHealth['score'] as num?)?.toInt() ?? 82,
    );

    setState(() {
      _isThinking = false;
      _messages.add(
        _ChatMessage(
          text: response.text,
          isUser: false,
          timestamp: DateTime.now(),
          actionTypes: response.actionTypes,
        ),
      );
    });
    _scrollToBottom();
  }

  List<AiActionButton> _buildActionButtons(List<String> actionTypes) {
    final List<AiActionButton> buttons = [];

    for (final type in actionTypes) {
      switch (type) {
        case 'open_goal':
          buttons.add(AiActionButton(
            label: 'Open Goals',
            icon: Icons.flag_rounded,
            color: AppTheme.cyan,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen())),
          ));
          break;
        case 'open_investment':
          buttons.add(AiActionButton(
            label: 'Investment Planner',
            icon: Icons.trending_up_rounded,
            color: AppTheme.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentScreen())),
          ));
          break;
        case 'create_budget':
          buttons.add(AiActionButton(
            label: 'Budget Manager',
            icon: Icons.pie_chart_outline_rounded,
            color: AppTheme.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
          ));
          break;
        case 'open_car_calc':
          buttons.add(AiActionButton(
            label: 'Car Calculator',
            icon: Icons.directions_car_rounded,
            color: AppTheme.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CarAffordabilityScreen())),
          ));
          break;
        case 'future_sim':
          buttons.add(AiActionButton(
            label: 'Wealth Simulator',
            icon: Icons.auto_graph_rounded,
            color: AppTheme.brightPurple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPlannerScreen())),
          ));
          break;
        case 'scan_receipt':
          buttons.add(AiActionButton(
            label: 'Scan Receipt',
            icon: Icons.document_scanner_rounded,
            color: AppTheme.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiptScannerScreen())),
          ));
          break;
        case 'view_leaks':
          buttons.add(AiActionButton(
            label: 'Money Leaks',
            icon: Icons.water_drop_outlined,
            color: AppTheme.red,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoneyLeakScreen())),
          ));
          break;
        case 'open_tax':
          buttons.add(AiActionButton(
            label: 'Tax Saver',
            icon: Icons.receipt_long_rounded,
            color: AppTheme.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxSaverScreen())),
          ));
          break;
        case 'review_subs':
          buttons.add(AiActionButton(
            label: 'Subscriptions',
            icon: Icons.subscriptions_outlined,
            color: AppTheme.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
          ));
          break;
        case 'import_statement':
          buttons.add(AiActionButton(
            label: 'Bank Statement',
            icon: Icons.upload_file_rounded,
            color: AppTheme.cyan,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankStatementImportScreen())),
          ));
          break;
      }
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B16).withValues(alpha: 0.8),
        elevation: 0,
        title: Row(
          children: [
            const AiFinancialOrb(size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FINPILOT AI COACH',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online • Financial intelligence active',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary, size: 20),
            tooltip: 'Reset Conversation',
            onPressed: () {
              AiFinancialCoachService.resetMemory();
              setState(() {
                _messages.clear();
                _messages.add(
                  _ChatMessage(
                    text: 'Memory refreshed. How can I help you optimize your finances today?',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Messages Area
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length + (_isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isThinking && index == _messages.length) {
                      return const AiMessageBubble(
                        message: '',
                        isUser: false,
                        isThinking: true,
                      );
                    }

                    final msg = _messages[index];
                    return AiMessageBubble(
                      message: msg.text,
                      isUser: msg.isUser,
                      timestamp: msg.timestamp,
                      actionButtons: _buildActionButtons(msg.actionTypes),
                    );
                  },
                ),
              ),

              // Dynamic Suggestion Chips
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _defaultSuggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final suggestion = _defaultSuggestions[index];
                    return ActionChip(
                      label: Text(
                        suggestion,
                        style: const TextStyle(
                          color: Color(0xFFF0F4FF),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: const Color(0xFF0F1629).withValues(alpha: 0.85),
                      side: BorderSide(color: const Color(0xFF5FE1FF).withValues(alpha: 0.25)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () => _handleUserQuery(suggestion),
                    );
                  },
                ),
              ),

              // Glass Input Bar
              GlassCard(
                borderRadius: 0,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                backgroundColor: const Color(0xFF0A0F20).withValues(alpha: 0.85),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    const Color(0xFF5FE1FF).withValues(alpha: 0.18),
                    const Color(0xFF7C6CFF).withValues(alpha: 0.12),
                  ],
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _handleUserQuery,
                          style: const TextStyle(color: AppTheme.white, fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Ask FinPilot: "Can I afford...", "Where to invest..."',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
                            filled: true,
                            fillColor: AppTheme.card,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppTheme.purple, width: 1.2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.purple, AppTheme.cyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.purple.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                          onPressed: () => _handleUserQuery(_textController.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'FinPilot AI provides educational financial intelligence. Not regulated financial advice. Actual returns may vary.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
