import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/budget_provider.dart';
import '../providers/finance_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);

  static const Color purple = Color(0xFF6C5CE7);
  static const Color lightPurple = Color(0xFF9A8CFF);
  static const Color cyan = Color(0xFF4CC9F0);

  static const Color green = Color(0xFF2DD4A8);
  static const Color orange = Color(0xFFFFB86B);
  static const Color red = Color(0xFFFF6B81);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final finance = context.watch<FinanceProvider>();

    final transactions = finance.transactions;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: RefreshIndicator(
                    color: purple,
                    backgroundColor: cardColor,
                    onRefresh: () async {
                      await Future.delayed(
                        const Duration(milliseconds: 700),
                      );
                    },
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        35,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildBudgetOverview(
                            budget,
                            transactions,
                          ),

                          const SizedBox(height: 22),

                          _buildBudgetHealth(
                            budget,
                            transactions,
                          ),

                          const SizedBox(height: 28),

                          _sectionHeader(
                            title: 'MONTHLY BUDGET',
                            subtitle:
                                'Control your overall spending',
                            action: 'Edit',
                            onTap: () =>
                                _showMonthlyBudgetDialog(
                              budget,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _buildMonthlyBudgetCard(
                            budget,
                            transactions,
                          ),

                          const SizedBox(height: 28),

                          _sectionHeader(
                            title: 'CATEGORY BUDGETS',
                            subtitle:
                                'Track spending by category',
                            action: 'Add',
                            onTap: () =>
                                _showAddCategoryDialog(
                              budget,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _buildCategoryBudgets(
                            budget,
                            transactions,
                          ),

                          const SizedBox(height: 28),

                          _buildSpendingInsight(
                            budget,
                            transactions,
                          ),

                          const SizedBox(height: 25),

                          _buildBudgetActions(
                            budget,
                          ),
                        ],
                      ),
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

  Widget _buildBackground() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withValues(alpha: 0.10),
              ),
            ),
          ),

          Positioned(
            top: 400,
            left: -130,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withValues(alpha: 0.05),
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
      padding: const EdgeInsets.fromLTRB(
        20,
        15,
        20,
        10,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 45,
              height: 45,
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
                  'FINANCIAL CONTROL',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Budget Planner',
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
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  purple,
                  cyan,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildBudgetOverview(
    BudgetProvider budget,
    List<TransactionModel> transactions,
  ) {
    final spent = budget.totalExpense(transactions);
    final remaining =
        budget.remainingBudget(transactions);

    final percentage =
        budget.budgetPercentage(transactions)
            .clamp(0.0, 1.0)
            .toDouble();

    final status = budget.budgetStatus(transactions);

    final statusColor =
        _statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFF382783),
            Color(0xFF121B36),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.30),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'MONTHLY BUDGET',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(
                        alpha: 0.20,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                '₹${_formatAmount(budget.monthlyBudget)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Total spending limit for this month',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.55,
                  ),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 24),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 10,
                  backgroundColor:
                      Colors.white.withValues(
                    alpha: 0.12,
                  ),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(
                    percentage >= 1
                        ? red
                        : percentage >= 0.8
                            ? orange
                            : cyan,
                  ),
                ),
              ),

              const SizedBox(height: 17),

              Row(
                children: [
                  Expanded(
                    child: _overviewStat(
                      label: 'SPENT',
                      value:
                          '₹${_formatCompact(spent)}',
                      icon:
                          Icons.arrow_upward_rounded,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 42,
                    color: Colors.white.withValues(
                      alpha: 0.12,
                    ),
                  ),

                  Expanded(
                    child: _overviewStat(
                      label: 'REMAINING',
                      value:
                          '₹${_formatCompact(math.max(0.0, remaining))}',
                      icon:
                          Icons.account_balance_wallet_outlined,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 42,
                    color: Colors.white.withValues(
                      alpha: 0.12,
                    ),
                  ),

                  Expanded(
                    child: _overviewStat(
                      label: 'USED',
                      value:
                          '${(percentage * 100).toStringAsFixed(0)}%',
                      icon:
                          Icons.pie_chart_outline_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white60,
            size: 15,
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUDGET HEALTH
  // ============================================================

  Widget _buildBudgetHealth(
    BudgetProvider budget,
    List<TransactionModel> transactions,
  ) {
    final status =
        budget.budgetStatus(transactions);

    final message =
        budget.budgetMessage(transactions);

    final color = _statusColor(status);

    final icon = _statusIcon(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'BUDGET HEALTH • $status',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
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
  // MONTHLY BUDGET CARD
  // ============================================================

  Widget _buildMonthlyBudgetCard(
    BudgetProvider budget,
    List<TransactionModel> transactions,
  ) {
    final spent =
        budget.totalExpense(transactions);

    final remaining =
        budget.remainingBudget(transactions);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _monthlyRow(
            icon:
                Icons.account_balance_wallet_outlined,
            title: 'Monthly Limit',
            value:
                '₹${_formatAmount(budget.monthlyBudget)}',
            color: purple,
          ),

          _divider(),

          _monthlyRow(
            icon: Icons.payments_outlined,
            title: 'Total Spent',
            value: '₹${_formatAmount(spent)}',
            color: red,
          ),

          _divider(),

          _monthlyRow(
            icon: Icons.savings_outlined,
            title: 'Available',
            value:
                '₹${_formatAmount(math.max(0.0, remaining))}',
            color: green,
          ),
        ],
      ),
    );
  }

  Widget _monthlyRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 15),
      child: Divider(
        height: 1,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }

  // ============================================================
  // CATEGORY BUDGETS
  // ============================================================

  Widget _buildCategoryBudgets(
    BudgetProvider budget,
    List<TransactionModel> transactions,
  ) {
    if (budget.categoryBudgets.isEmpty) {
      return _emptyCategories();
    }

    return Column(
      children: budget.categoryBudgets.entries
          .map(
            (entry) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: _categoryBudgetCard(
                category: entry.key,
                limit: entry.value,
                budget: budget,
                transactions: transactions,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _categoryBudgetCard({
    required String category,
    required double limit,
    required BudgetProvider budget,
    required List<TransactionModel> transactions,
  }) {
    final spent =
        budget.categorySpent(category, transactions);

    final remaining =
        budget.categoryRemaining(category, transactions);

    final percentage =
        budget.categoryPercentage(
          category,
          transactions,
        );

    final progress =
        percentage.clamp(0.0, 1.0).toDouble();

    final isOver =
        budget.isCategoryOverBudget(
      category,
      transactions,
    );

    final color = isOver
        ? red
        : percentage >= 0.8
            ? orange
            : _categoryColor(category);

    return GestureDetector(
      onTap: () => _showEditCategoryDialog(
        budget,
        category,
        limit,
      ),
      onLongPress: () =>
          _showCategoryOptions(
        budget,
        category,
        limit,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _categoryIcon(category),
                    color: color,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '₹${_formatCompact(spent)} of ₹${_formatCompact(limit)}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      remaining >= 0
                          ? '₹${_formatCompact(remaining)} left'
                          : 'Over limit',
                      style: TextStyle(
                        color: remaining >= 0
                            ? Colors.white38
                            : red,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor:
                    Colors.white.withValues(
                  alpha: 0.06,
                ),
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  color,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white24,
                  size: 13,
                ),

                const SizedBox(width: 5),

                const Text(
                  'Tap to edit budget',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 9,
                  ),
                ),

                const Spacer(),

                if (isOver)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: red.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'OVER BUDGET',
                      style: TextStyle(
                        color: red,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY CATEGORIES
  // ============================================================

  Widget _emptyCategories() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.category_outlined,
            color: Colors.white24,
            size: 38,
          ),

          SizedBox(height: 12),

          Text(
            'No category budgets',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Create a category to start planning',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SPENDING INSIGHT
  // ============================================================

  Widget _buildSpendingInsight(
    BudgetProvider budget,
    List<TransactionModel> transactions,
  ) {
    final overCategories =
        budget.overBudgetCategories(
      transactions,
    );

    final warningCategories =
        budget.warningCategories(
      transactions,
    );

    String title;
    String message;
    Color color;
    IconData icon;

    if (overCategories.isNotEmpty) {
      title = 'SPENDING ALERT';

      message =
          '${overCategories.join(', ')} ${overCategories.length == 1 ? 'has' : 'have'} exceeded the allocated budget.';

      color = red;
      icon = Icons.warning_amber_rounded;
    } else if (warningCategories.isNotEmpty) {
      title = 'BUDGET WARNING';

      message =
          '${warningCategories.join(', ')} is approaching its spending limit.';

      color = orange;
      icon = Icons.notifications_active_outlined;
    } else {
      title = 'SMART INSIGHT';

      message =
          'Your category spending is currently under control. Keep tracking expenses for better financial planning.';

      color = cyan;
      icon = Icons.auto_awesome_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.14),
            purple.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.45,
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
  // BUDGET ACTIONS
  // ============================================================

  Widget _buildBudgetActions(
    BudgetProvider budget,
  ) {
    return Column(
      children: [
        _actionButton(
          icon: Icons.restart_alt_rounded,
          title: 'Reset Budget Plan',
          subtitle:
              'Restore your default monthly budget',
          color: orange,
          onTap: () => _confirmReset(budget),
        ),

        const SizedBox(height: 12),

        _actionButton(
          icon: Icons.info_outline_rounded,
          title: 'Budget Tips',
          subtitle:
              'Learn how to manage your money better',
          color: cyan,
          onTap: _showBudgetTips,
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
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
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    String? action,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
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
          ),
        ),

        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                action,
                style: const TextStyle(
                  color: lightPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // MONTHLY BUDGET DIALOG
  // ============================================================

  void _showMonthlyBudgetDialog(
    BudgetProvider budget,
  ) {
    final controller = TextEditingController(
      text: budget.monthlyBudget.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            20,
            22,
            MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                28,
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

              const Icon(
                Icons.account_balance_wallet_rounded,
                color: lightPurple,
                size: 32,
              ),

              const SizedBox(height: 12),

              const Text(
                'Set Monthly Budget',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose how much you want to spend this month',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: controller,
                keyboardType:
                    TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    color: lightPurple,
                    fontSize: 20,
                  ),
                  filled: true,
                  fillColor:
                      Colors.white.withValues(
                    alpha: 0.05,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(
                      controller.text.trim(),
                    );

                    if (amount != null &&
                        amount >= 0) {
                      budget.setMonthlyBudget(
                        amount,
                      );

                      Navigator.pop(context);

                      _showMessage(
                        'Monthly budget updated successfully',
                        green,
                      );
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'UPDATE BUDGET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  void _showAddCategoryDialog(
    BudgetProvider budget,
  ) {
    final categoryController =
        TextEditingController();

    final amountController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            20,
            22,
            MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                28,
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

              const Text(
                'Add Category Budget',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 24),

              _darkTextField(
                controller: categoryController,
                label: 'Category Name',
                icon: Icons.category_outlined,
              ),

              const SizedBox(height: 14),

              _darkTextField(
                controller: amountController,
                label: 'Budget Amount',
                icon:
                    Icons.account_balance_wallet_outlined,
                keyboardType:
                    TextInputType.number,
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final category =
                        categoryController.text.trim();

                    final amount =
                        double.tryParse(
                      amountController.text.trim(),
                    );

                    if (category.isEmpty ||
                        amount == null ||
                        amount < 0) {
                      return;
                    }

                    budget.addCategory(
                      category,
                      amount,
                    );

                    Navigator.pop(context);

                    _showMessage(
                      '$category budget added',
                      green,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'ADD CATEGORY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // EDIT CATEGORY
  // ============================================================

  void _showEditCategoryDialog(
    BudgetProvider budget,
    String category,
    double currentAmount,
  ) {
    final controller = TextEditingController(
      text: currentAmount.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            20,
            22,
            MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                28,
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

              Icon(
                _categoryIcon(category),
                color: _categoryColor(category),
                size: 32,
              ),

              const SizedBox(height: 10),

              Text(
                '$category Budget',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 22),

              TextField(
                controller: controller,
                keyboardType:
                    TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    color: lightPurple,
                    fontSize: 19,
                  ),
                  filled: true,
                  fillColor:
                      Colors.white.withValues(
                    alpha: 0.05,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(
                      controller.text.trim(),
                    );

                    if (amount != null &&
                        amount >= 0) {
                      budget.setCategoryBudget(
                        category,
                        amount,
                      );

                      Navigator.pop(context);

                      _showMessage(
                        '$category budget updated',
                        green,
                      );
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CATEGORY OPTIONS
  // ============================================================

  void _showCategoryOptions(
    BudgetProvider budget,
    String category,
    double amount,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: cyan,
                  ),
                  title: const Text(
                    'Edit Budget',
                    style:
                        TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showEditCategoryDialog(
                      budget,
                      category,
                      amount,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: red,
                  ),
                  title: const Text(
                    'Remove Category',
                    style: TextStyle(color: red),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    budget.removeCategory(
                      category,
                    );

                    _showMessage(
                      '$category removed',
                      red,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void _confirmReset(
    BudgetProvider budget,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: const Text(
            'Reset Budgets?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'This will restore the default monthly and category budgets.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text(
                'Cancel',
                style:
                    TextStyle(color: Colors.white54),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                budget.resetBudgets();

                Navigator.pop(context);

                _showMessage(
                  'Budget plan reset successfully',
                  green,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
              ),
              child: const Text(
                'Reset',
                style:
                    TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUDGET TIPS
  // ============================================================

  void _showBudgetTips() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: lightPurple,
                  size: 34,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Smart Budget Tips',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 22),

                _tipTile(
                  '50/30/20 Rule',
                  'Try allocating 50% for needs, 30% for wants and 20% for savings.',
                ),

                _tipTile(
                  'Track Daily',
                  'Add every expense immediately to maintain accurate budget data.',
                ),

                _tipTile(
                  'Avoid Overspending',
                  'Set realistic limits for categories where you spend the most.',
                ),

                _tipTile(
                  'Review Monthly',
                  'Analyze your spending patterns and adjust your budget every month.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tipTile(
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 11,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.04,
        ),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: cyan,
            size: 18,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white38,
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
  // TEXT FIELD
  // ============================================================

  Widget _darkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white38,
        ),
        prefixIcon: Icon(
          icon,
          color: lightPurple,
        ),
        filled: true,
        fillColor: Colors.white.withValues(
          alpha: 0.05,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(23),
      border: Border.all(
        color: Colors.white.withValues(
          alpha: 0.07,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'Over Budget':
        return red;

      case 'Critical':
        return red;

      case 'Warning':
        return orange;

      case 'Moderate':
        return cyan;

      default:
        return green;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Over Budget':
        return Icons.warning_rounded;

      case 'Critical':
        return Icons.error_outline_rounded;

      case 'Warning':
        return Icons.warning_amber_rounded;

      case 'Moderate':
        return Icons.info_outline_rounded;

      default:
        return Icons.check_circle_outline_rounded;
    }
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
        return Icons.flight_outlined;

      case 'investment':
        return Icons.trending_up_rounded;

      default:
        return Icons.category_outlined;
    }
  }

  // ============================================================
  // CATEGORY COLOR
  // ============================================================

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return orange;

      case 'transport':
        return cyan;

      case 'shopping':
        return purple;

      case 'bills':
        return red;

      case 'entertainment':
        return lightPurple;

      case 'health':
        return green;

      case 'education':
        return cyan;

      case 'travel':
        return orange;

      default:
        return lightPurple;
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

  String _formatCompact(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    }

    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }

    return amount.toStringAsFixed(0);
  }
}