import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/financial_goal.dart';
import '../providers/finance_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/budget_provider.dart';

import '../widgets/ai_financial_orb.dart';

import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'transactions_screen.dart';
import 'goal_screen.dart';
import 'investment_screen.dart';
import 'ai_insights_screen.dart';
import 'ai_coach_screen.dart';
import 'receipt_scanner_screen.dart';
import 'bank_statement_import_screen.dart';
import 'savings_planner_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['1M', '3M', '6M', '1Y'];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final goals = goalProvider.goals.isNotEmpty ? goalProvider.goals : finance.goals;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;

    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF7C6CFF),
          backgroundColor: const Color(0xFF111827),
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 18,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(finance),
                    const SizedBox(height: 24),
                    if (isDesktop)
                      _buildDesktopGrid(finance, goals, budgetProvider)
                    else
                      _buildMobileStack(finance, goals, budgetProvider),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP DUAL-COLUMN LAYOUT
  // ============================================================
  Widget _buildDesktopGrid(FinanceProvider finance, List<FinancialGoal> goals, BudgetProvider budgetProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (64%): Hero Wealth, Command Grid, Spending Intelligence, Goals
        Expanded(
          flex: 64,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroWealthCard(finance),
              const SizedBox(height: 24),
              _buildFinancialCommandGrid(finance, goals, budgetProvider),
              const SizedBox(height: 24),
              _buildSpendingIntelligence(finance),
              const SizedBox(height: 24),
              _buildGoalCommandCenter(goals),
            ],
          ),
        ),
        const SizedBox(width: 28),
        // Right Column (36%): AI Briefing, Next Best Move, Quick Actions, Timeline, AI Entry
        Expanded(
          flex: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAiFinancialBriefing(finance),
              const SizedBox(height: 24),
              _buildNextBestMove(finance),
              const SizedBox(height: 24),
              _buildActionControlPills(),
              const SizedBox(height: 24),
              _buildRecentActivityTimeline(finance),
              const SizedBox(height: 24),
              _buildAiCoachEntryBanner(),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE VERTICAL STACK
  // ============================================================
  Widget _buildMobileStack(FinanceProvider finance, List<FinancialGoal> goals, BudgetProvider budgetProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroWealthCard(finance),
        const SizedBox(height: 20),
        _buildAiFinancialBriefing(finance),
        const SizedBox(height: 20),
        _buildNextBestMove(finance),
        const SizedBox(height: 20),
        _buildActionControlPills(),
        const SizedBox(height: 24),
        _buildFinancialCommandGrid(finance, goals, budgetProvider),
        const SizedBox(height: 24),
        _buildSpendingIntelligence(finance),
        const SizedBox(height: 24),
        _buildGoalCommandCenter(goals),
        const SizedBox(height: 24),
        _buildRecentActivityTimeline(finance),
        const SizedBox(height: 24),
        _buildAiCoachEntryBanner(),
      ],
    );
  }

  // ============================================================
  // 1. TOP HEADER (FINPILOT AI 2.0 + PROFILE + LIVE STATUS)
  // ============================================================
  Widget _buildTopHeader(FinanceProvider finance) {
    final greeting = _getGreeting();
    final name = finance.userName.isNotEmpty ? finance.userName : 'Harshika';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'FINPILOT AI',
                  style: TextStyle(
                    color: Color(0xFF5FE1FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6CFF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF7C6CFF).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    '2.0 OS',
                    style: TextStyle(
                      color: Color(0xFF9B8CFF),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$greeting, $name',
              style: const TextStyle(
                color: Color(0xFFF5F7FB),
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF48D597),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'AI FINANCIAL MONITOR ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF737D91),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIInsightsScreen())),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFFB8C0D0),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C6CFF).withValues(alpha: 0.5), width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF192235),
                  child: Text(
                    'H',
                    style: TextStyle(
                      color: Color(0xFF5FE1FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // 2. HERO WEALTH COMMAND CENTER
  // ============================================================
  Widget _buildHeroWealthCard(FinanceProvider finance) {
    final balance = finance.balance;
    final income = finance.monthlyIncome > 0 ? finance.monthlyIncome : (finance.totalIncome > 0 ? finance.totalIncome : 77000.0);
    final expenses = finance.monthlyExpenses > 0 ? finance.monthlyExpenses : (finance.totalExpense > 0 ? finance.totalExpense : 42000.0);
    final savings = math.max(0.0, income - expenses);
    final savingsRate = income > 0 ? ((savings / income) * 100).toStringAsFixed(1) : '0.0';

    final Map<int, List<double>> curveMap = {
      0: [balance * 0.94, balance * 0.95, balance * 0.93, balance * 0.97, balance * 0.96, balance * 0.99, balance],
      1: [balance * 0.88, balance * 0.90, balance * 0.89, balance * 0.94, balance * 0.92, balance * 0.97, balance],
      2: [balance * 0.79, balance * 0.84, balance * 0.82, balance * 0.89, balance * 0.92, balance * 0.95, balance],
      3: [balance * 0.65, balance * 0.72, balance * 0.78, balance * 0.83, balance * 0.89, balance * 0.94, balance],
    };
    final points = curveMap[_selectedFilterIndex] ?? curveMap[0]!;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1220),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL WEALTH',
                      style: TextStyle(
                        color: Color(0xFF737D91),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${_formatAmount(balance)}',
                          style: const TextStyle(
                            color: Color(0xFFF5F7FB),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF48D597).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up_rounded, color: Color(0xFF48D597), size: 14),
                              SizedBox(width: 4),
                              Text(
                                '+12.4% vs last month',
                                style: TextStyle(
                                  color: Color(0xFF48D597),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151D2D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_filters.length, (idx) {
                      final isSel = _selectedFilterIndex == idx;
                      return InkWell(
                        onTap: () => setState(() => _selectedFilterIndex = idx),
                        borderRadius: BorderRadius.circular(9),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF7C6CFF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            _filters[idx],
                            style: TextStyle(
                              color: isSel ? Colors.white : const Color(0xFF737D91),
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: CustomPaint(
                painter: _HeroChartPainter(
                  points: points,
                  lineColor: const Color(0xFF5FE1FF),
                  fillColor: const Color(0xFF5FE1FF).withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeroSubMetric('Income', '₹${_formatCompact(income)}', const Color(0xFF48D597)),
                _buildHeroSubMetric('Expenses', '₹${_formatCompact(expenses)}', const Color(0xFFFF667F)),
                _buildHeroSubMetric('Savings', '₹${_formatCompact(savings)}', const Color(0xFF5FE1FF)),
                _buildHeroSubMetric('Savings Rate', '$savingsRate%', const Color(0xFF7C6CFF)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSubMetric(String label, String value, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF737D91),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: accent,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 3. AI FINANCIAL BRIEFING (PREMIUM DISTINCT PANEL)
  // ============================================================
  Widget _buildAiFinancialBriefing(FinanceProvider finance) {
    final expenses = finance.monthlyExpenses > 0 ? finance.monthlyExpenses : (finance.totalExpense > 0 ? finance.totalExpense : 35000.0);
    final foodEstimate = (expenses * 0.32).round();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C6CFF).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6CFF).withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AiFinancialOrb(size: 34),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINPILOT INTELLIGENCE',
                      style: TextStyle(
                        color: Color(0xFF5FE1FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your financial briefing',
                      style: TextStyle(
                        color: Color(0xFFF5F7FB),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF48D597).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HEALTHY',
                  style: TextStyle(color: Color(0xFF48D597), fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF080C15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your cash flow is healthy this month, but discretionary spending is trending 14% above your normal range.',
                  style: TextStyle(
                    color: Color(0xFFB8C0D0),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reducing food delivery & dining (currently ~₹$foodEstimate) by ₹1,500 could help accelerate your current savings goal by 3 weeks.',
                  style: const TextStyle(
                    color: Color(0xFF5FE1FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiCoachScreen())),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                  label: const Text('ASK FINPILOT', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C6CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIInsightsScreen())),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                  label: const Text('VIEW INSIGHTS', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5FE1FF),
                    side: const BorderSide(color: Color(0xFF5FE1FF)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  // 4. NEXT BEST FINANCIAL MOVE
  // ============================================================
  Widget _buildNextBestMove(FinanceProvider finance) {
    final income = finance.monthlyIncome > 0 ? finance.monthlyIncome : (finance.totalIncome > 0 ? finance.totalIncome : 77000.0);
    final expenses = finance.monthlyExpenses > 0 ? finance.monthlyExpenses : (finance.totalExpense > 0 ? finance.totalExpense : 42000.0);
    final surplus = math.max(0.0, income - expenses);
    final emergencyFundNeed = expenses * 3;

    String actionTitle = 'Increase Monthly Savings Allocation';
    String actionWhy = 'Your monthly savings capacity of ₹${_formatCompact(surplus)} comfortably absorbs an extra ₹2,000 commitment.';
    String actionImpact = 'Accelerates your priority goals by approximately 18 days and guards against lifestyle inflation.';
    VoidCallback onCta = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen()));

    if (finance.balance < emergencyFundNeed) {
      actionTitle = 'Bolster 3-Month Emergency Reserve';
      actionWhy = 'Liquid balance (₹${_formatCompact(finance.balance)}) is below the non-negotiable 3-month living expense reserve of ₹${_formatCompact(emergencyFundNeed)}.';
      actionImpact = 'Guarantees complete cash buffer during medical or job transitions without debt.';
      onCta = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPlannerScreen()));
    } else if (finance.investments.isEmpty && surplus > 10000) {
      actionTitle = 'Deploy Unallocated Cash Surplus';
      actionWhy = 'Surplus cash is suffering inflationary drag in low-interest accounts.';
      actionImpact = 'A disciplined monthly SIP compounding at 12% generates significant net worth gains over 5 years.';
      onCta = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentScreen()));
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF48D597).withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF48D597).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flash_on_rounded, color: Color(0xFF48D597), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR NEXT BEST MOVE',
                      style: TextStyle(
                        color: Color(0xFF48D597),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'High-leverage action',
                      style: TextStyle(color: Color(0xFFF5F7FB), fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            actionTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _buildNextMoveBullet('WHY', actionWhy),
          const SizedBox(height: 6),
          _buildNextMoveBullet('IMPACT', actionImpact),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCta,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48D597),
                foregroundColor: const Color(0xFF05070D),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'TAKE ACTION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMoveBullet(String tag, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tag,
            style: const TextStyle(color: Color(0xFF737D91), fontSize: 9, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(color: Color(0xFFB8C0D0), fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 5. FINANCIAL COMMAND GRID
  // ============================================================
  Widget _buildFinancialCommandGrid(FinanceProvider finance, List<FinancialGoal> goals, BudgetProvider budgetProvider) {
    final income = finance.monthlyIncome > 0 ? finance.monthlyIncome : (finance.totalIncome > 0 ? finance.totalIncome : 77000.0);
    final expenses = finance.monthlyExpenses > 0 ? finance.monthlyExpenses : (finance.totalExpense > 0 ? finance.totalExpense : 42000.0);
    final savings = math.max(0.0, income - expenses);
    final savingsRate = income > 0 ? (savings / income) * 100 : 0.0;
    final healthScore = (finance.financialHealth['score'] as num?)?.toInt() ?? 82;
    final portfolioVal = finance.totalPortfolioValue > 0 ? finance.totalPortfolioValue : 24000.0;
    final topGoalPct = goals.isNotEmpty && goals.first.targetAmount > 0
        ? ((goals.first.savedAmount / goals.first.targetAmount) * 100).clamp(0, 100).toInt()
        : 56;

    final cards = [
      {
        'title': 'CASH FLOW',
        'value': '₹${_formatAmount(savings)}',
        'sub': '+8.5% net inflow',
        'subColor': const Color(0xFF48D597),
        'icon': Icons.swap_vert_rounded,
        'accent': const Color(0xFF48D597),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
      },
      {
        'title': 'BUDGET HEALTH',
        'value': '82%',
        'sub': 'Disciplined burn',
        'subColor': const Color(0xFF5FE1FF),
        'icon': Icons.pie_chart_outline_rounded,
        'accent': const Color(0xFF5FE1FF),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIInsightsScreen())),
      },
      {
        'title': 'SAVINGS',
        'value': '₹${_formatAmount(savings)}',
        'sub': '${savingsRate.toStringAsFixed(1)}% rate',
        'subColor': const Color(0xFF7C6CFF),
        'icon': Icons.savings_outlined,
        'accent': const Color(0xFF7C6CFF),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPlannerScreen())),
      },
      {
        'title': 'FINANCIAL HEALTH',
        'value': '$healthScore / 100',
        'sub': healthScore >= 80 ? 'Tier 1 Prime' : 'Moderate',
        'subColor': const Color(0xFF48D597),
        'icon': Icons.health_and_safety_outlined,
        'accent': const Color(0xFF48D597),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPlannerScreen())),
      },
      {
        'title': 'INVESTMENTS',
        'value': '₹${_formatAmount(portfolioVal)}',
        'sub': '+14.2% CAGR est',
        'subColor': const Color(0xFF5FE1FF),
        'icon': Icons.trending_up_rounded,
        'accent': const Color(0xFF5FE1FF),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentScreen())),
      },
      {
        'title': 'GOALS',
        'value': '$topGoalPct% on track',
        'sub': '${goals.length} active priority',
        'subColor': const Color(0xFF7C6CFF),
        'icon': Icons.flag_outlined,
        'accent': const Color(0xFF7C6CFF),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen())),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 2);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.6,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final c = cards[index];
            final accent = c['accent'] as Color;
            return InkWell(
              onTap: c['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c['title'] as String,
                          style: const TextStyle(
                            color: Color(0xFF737D91),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Icon(c['icon'] as IconData, color: accent, size: 16),
                      ],
                    ),
                    Text(
                      c['value'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF5F7FB),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(color: c['subColor'] as Color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          c['sub'] as String,
                          style: TextStyle(
                            color: c['subColor'] as Color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // 6. SPENDING INTELLIGENCE
  // ============================================================
  Widget _buildSpendingIntelligence(FinanceProvider finance) {
    final Map<String, double> catMap = {};
    for (final tx in finance.transactions.where((t) => t.isExpense)) {
      catMap[tx.category] = (catMap[tx.category] ?? 0.0) + tx.amount;
    }

    if (catMap.isEmpty) {
      catMap['Food & Dining'] = 14500;
      catMap['Shopping'] = 8200;
      catMap['Transport'] = 4500;
      catMap['Bills & Utilities'] = 6200;
      catMap['Entertainment'] = 3100;
      catMap['Subscriptions'] = 2400;
    }

    final totalExp = catMap.values.fold(0.0, (a, b) => a + b);
    final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      const Color(0xFF7C6CFF),
      const Color(0xFF5FE1FF),
      const Color(0xFF48D597),
      const Color(0xFFF5B74F),
      const Color(0xFFFF667F),
      const Color(0xFF9B8CFF),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPENDING INTELLIGENCE',
                    style: TextStyle(
                      color: Color(0xFF737D91),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Where your money is moving',
                    style: TextStyle(color: Color(0xFFF5F7FB), fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Text(
                'Total: ₹${_formatAmount(totalExp)}',
                style: const TextStyle(color: Color(0xFF5FE1FF), fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: sorted.take(6).map((entry) {
                  final idx = sorted.indexOf(entry);
                  final pct = totalExp > 0 ? entry.value / totalExp : 0.16;
                  return Expanded(
                    flex: (pct * 100).toInt().clamp(1, 100),
                    child: Container(color: colors[idx % colors.length]),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...sorted.take(5).map((entry) {
            final idx = sorted.indexOf(entry);
            final pct = totalExp > 0 ? (entry.value / totalExp) * 100 : 0.0;
            final color = colors[idx % colors.length];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: Color(0xFFF5F7FB), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Color(0xFF737D91), fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '₹${_formatAmount(entry.value)}',
                    style: const TextStyle(color: Color(0xFFF5F7FB), fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF080C15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Color(0xFF5FE1FF), size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Food delivery is currently your fastest-growing discretionary category (+18% vs last month).',
                    style: TextStyle(color: Color(0xFFB8C0D0), fontSize: 11.5, height: 1.4),
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
  // 7. GOAL COMMAND CENTER
  // ============================================================
  Widget _buildGoalCommandCenter(List<FinancialGoal> goals) {
    final topGoal = goals.isNotEmpty
        ? goals.first
        : FinancialGoal(
            id: 'demo_macbook',
            title: 'MacBook Pro M4',
            targetAmount: 80000,
            currentAmount: 45000,
            category: GoalCategory.gadget,
            priority: GoalPriority.high,
            createdDate: DateTime.now().subtract(const Duration(days: 30)),
            targetDate: DateTime(2026, 12, 31),
          );

    final pct = topGoal.targetAmount > 0 ? (topGoal.savedAmount / topGoal.targetAmount).clamp(0.0, 1.0) : 0.56;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR FINANCIAL PRIORITIES',
                    style: TextStyle(
                      color: Color(0xFF737D91),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Goal Command Center',
                    style: TextStyle(color: Color(0xFFF5F7FB), fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen())),
                child: const Text(
                  'VIEW ALL →',
                  style: TextStyle(color: Color(0xFF5FE1FF), fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF7C6CFF).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      topGoal.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFF5FE1FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5FE1FF)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved: ₹${_formatAmount(topGoal.savedAmount)}',
                      style: const TextStyle(color: Color(0xFFB8C0D0), fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Target: ₹${_formatAmount(topGoal.targetAmount)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFF48D597), size: 14),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI: At your current savings pace, you\'re approximately 18 days ahead of schedule.',
                        style: TextStyle(color: Color(0xFF48D597), fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('VIEW GOAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPlannerScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C6CFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('OPTIMIZE PLAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 8. QUICK ACTION CONTROL PILLS
  // ============================================================
  Widget _buildActionControlPills() {
    final actions = [
      {'label': 'Scan Receipt', 'icon': Icons.document_scanner_rounded, 'color': const Color(0xFF5FE1FF), 'tap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiptScannerScreen()))},
      {'label': 'Statement', 'icon': Icons.upload_file_rounded, 'color': const Color(0xFF7C6CFF), 'tap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankStatementImportScreen()))},
      {'label': 'Add Expense', 'icon': Icons.remove_circle_outline_rounded, 'color': const Color(0xFFFF667F), 'tap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()))},
      {'label': 'Add Income', 'icon': Icons.add_circle_outline_rounded, 'color': const Color(0xFF48D597), 'tap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen()))},
    ];

    return Row(
      children: actions.map((item) {
        final color = item['color'] as Color;
        return Expanded(
          child: InkWell(
            onTap: item['tap'] as VoidCallback,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  Icon(item['icon'] as IconData, color: color, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF5F7FB),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // 9. RECENT ACTIVITY (CLEAN LUXURY TRANSACTION TIMELINE)
  // ============================================================
  Widget _buildRecentActivityTimeline(FinanceProvider finance) {
    final recent = finance.transactions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECENT TELEMETRY',
                    style: TextStyle(
                      color: Color(0xFF737D91),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Transaction Timeline',
                    style: TextStyle(color: Color(0xFFF5F7FB), fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                child: const Text(
                  'VIEW ALL →',
                  style: TextStyle(color: Color(0xFF5FE1FF), fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No transaction telemetry yet.', style: TextStyle(color: Color(0xFF737D91))),
              ),
            )
          else
            ...recent.map((tx) {
              final isExp = tx.isExpense;
              final color = isExp ? const Color(0xFFFF667F) : const Color(0xFF48D597);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isExp ? Icons.north_east_rounded : Icons.south_west_rounded,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFFF5F7FB), fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${tx.category} • ${_formatDate(tx.date)}',
                            style: const TextStyle(color: Color(0xFF737D91), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isExp ? "-" : "+"}₹${_formatAmount(tx.amount)}',
                      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================
  // 10. AI COACH QUICK-LAUNCH BANNER
  // ============================================================
  Widget _buildAiCoachEntryBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C6CFF).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              AiFinancialOrb(size: 28),
              SizedBox(width: 10),
              Text(
                'HAVE A FINANCIAL QUESTION?',
                style: TextStyle(color: Color(0xFF5FE1FF), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ask FinPilot anything about your money.',
            style: TextStyle(color: Color(0xFFF5F7FB), fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiCoachScreen())),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1220),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: Color(0xFF737D91), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'e.g. "Can I afford a car next year?"',
                      style: TextStyle(color: Color(0xFF737D91), fontSize: 12),
                    ),
                  ),
                  Text(
                    'ASK AI',
                    style: TextStyle(color: Color(0xFF7C6CFF), fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMATTERS
  // ============================================================
  String _formatAmount(double val) {
    return val.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _formatCompact(double val) {
    if (val >= 10000000) return '${(val / 10000000).toStringAsFixed(1)}Cr';
    if (val >= 100000) return '${(val / 100000).toStringAsFixed(1)}L';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}k';
    return val.round().toString();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

// ============================================================
// CUSTOM BEZIER HERO CHART PAINTER
// ============================================================
class _HeroChartPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;

  _HeroChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minVal = points.reduce(math.min);
    final maxVal = points.reduce(math.max);
    final range = maxVal - minVal > 0 ? maxVal - minVal : 1.0;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (points.length - 1);

    double getY(double val) {
      final normalized = (val - minVal) / range;
      return size.height - (normalized * (size.height - 16)) - 8;
    }

    path.moveTo(0, getY(points[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getY(points[0]));

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = i * stepX;
      final y1 = getY(points[i]);
      final x2 = (i + 1) * stepX;
      final y2 = getY(points[i + 1]);

      final midX = (x1 + x2) / 2;
      path.cubicTo(midX, y1, midX, y2, x2, y2);
      fillPath.cubicTo(midX, y1, midX, y2, x2, y2);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, areaPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final lastX = (points.length - 1) * stepX;
    final lastY = getY(points.last);
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(Offset(lastX, lastY), 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _HeroChartPainter oldDelegate) => true;
}