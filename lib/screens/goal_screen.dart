import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/financial_goal.dart';
import '../providers/goal_provider.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF111C31);
  static const Color primaryPurple = Color(0xFF7C5CFC);
  static const Color cyan = Color(0xFF4CC9F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 10,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Goal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: _showAddGoalSheet,
      ),

      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryPurple,
              ),
            );
          }

          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _header(provider),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _overviewCard(provider),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _statisticsRow(provider),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: _sectionHeader(),
                  ),
                ),

                if (provider.goals.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _emptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      120,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = provider.goals[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _goalCard(goal),
                          );
                        },
                        childCount: provider.goals.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header(GoalProvider provider) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                primaryPurple,
                cyan,
              ],
            ),
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Goals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Turn your dreams into reality',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () => _showAIInsight(provider),
          icon: const Icon(
            Icons.auto_awesome_rounded,
            color: cyan,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW CARD
  // ============================================================

  Widget _overviewCard(GoalProvider provider) {
    final double progress =
        provider.overallProgress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            primaryPurple.withValues(alpha: 0.85),
            const Color(0xFF4434A8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.savings_rounded,
                color: Colors.white,
                size: 25,
              ),
              const SizedBox(width: 10),
              const Text(
                'Total Savings Progress',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 11,
                    strokeCap: StrokeCap.round,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.18),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${_formatAmount(provider.totalSavedAmount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of ₹${_formatAmount(provider.totalTargetAmount)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Keep going! Every contribution brings you closer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _statisticsRow(GoalProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.flag_rounded,
            value: provider.totalGoals.toString(),
            label: 'Total',
            color: primaryPurple,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _statCard(
            icon: Icons.check_circle_rounded,
            value: provider.completedGoalsCount.toString(),
            label: 'Completed',
            color: Colors.greenAccent,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department_rounded,
            value: provider.activeGoals.length.toString(),
            label: 'Active',
            color: Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader() {
    return const Row(
      children: [
        Text(
          'Your Goals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        Spacer(),
        Text(
          'Track your progress',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GOAL CARD
  // ============================================================

  Widget _goalCard(FinancialGoal goal) {
    final color = _categoryColor(goal.category);

    final double progress =
        goal.progressPercentage.clamp(0.0, 1.0).toDouble();

    return GestureDetector(
      onTap: () => _showGoalDetails(goal),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: goal.isCompleted
                ? Colors.greenAccent.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _categoryIcon(goal.category),
                    color: color,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        _categoryLabel(goal.category),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                _priorityBadge(goal.priority),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Text(
                  '₹${_formatAmount(goal.currentAmount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Text(
                  ' / ₹${_formatAmount(goal.targetAmount)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor:
                    Colors.white.withValues(alpha: 0.07),
                valueColor:
                    AlwaysStoppedAnimation<Color>(color),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                if (goal.daysRemaining != null)
                  _infoChip(
                    icon: Icons.calendar_today_rounded,
                    text: '${goal.daysRemaining} days left',
                  ),

                const Spacer(),

                GestureDetector(
                  onTap: () => _showAddMoneySheet(goal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: primaryPurple.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: primaryPurple,
                          size: 17,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Add Money',
                          style: TextStyle(
                            color: primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
  // PRIORITY BADGE
  // ============================================================

  Widget _priorityBadge(GoalPriority priority) {
    late Color color;
    late String text;

    switch (priority) {
      case GoalPriority.low:
        color = Colors.greenAccent;
        text = 'Low';
        break;

      case GoalPriority.medium:
        color = Colors.orangeAccent;
        text = 'Medium';
        break;

      case GoalPriority.high:
        color = Colors.redAccent;
        text = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white38,
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryPurple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_outlined,
                size: 48,
                color: primaryPurple,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Goals Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Create your first financial goal and start building your future.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD GOAL
  // ============================================================

  void _showAddGoalSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final savedController = TextEditingController();
    final descriptionController = TextEditingController();

    GoalCategory selectedCategory = GoalCategory.other;
    GoalPriority selectedPriority = GoalPriority.medium;

    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Create New Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _inputField(
                      controller: titleController,
                      label: 'Goal Name',
                      icon: Icons.flag_rounded,
                    ),

                    const SizedBox(height: 14),

                    _inputField(
                      controller: amountController,
                      label: 'Target Amount',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 14),

                    _inputField(
                      controller: savedController,
                      label: 'Already Saved (Optional)',
                      icon: Icons.savings_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 14),

                    _inputField(
                      controller: descriptionController,
                      label: 'Description (Optional)',
                      icon: Icons.notes_rounded,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: GoalCategory.values.map(
                        (category) {
                          final selected =
                              selectedCategory == category;

                          return ChoiceChip(
                            label: Text(
                              _categoryLabel(category),
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setSheetState(() {
                                selectedCategory = category;
                              });
                            },
                            selectedColor:
                                primaryPurple.withValues(
                              alpha: 0.3,
                            ),
                            backgroundColor: cardColor,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          );
                        },
                      ).toList(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Priority',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: GoalPriority.values.map(
                        (priority) {
                          final selected =
                              selectedPriority == priority;

                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  priority.name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                ),
                                selected: selected,
                                onSelected: (_) {
                                  setSheetState(() {
                                    selectedPriority =
                                        priority;
                                  });
                                },
                                selectedColor:
                                    primaryPurple.withValues(
                                  alpha: 0.3,
                                ),
                                backgroundColor: cardColor,
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  color: selected
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),

                    const SizedBox(height: 18),

                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                          initialDate: selectedDate ??
                              DateTime.now().add(
                                const Duration(days: 90),
                              ),
                        );

                        if (date != null) {
                          setSheetState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: cyan,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? 'Set Target Date'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: TextStyle(
                                color: selectedDate == null
                                    ? Colors.white54
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(17),
                          ),
                        ),
                        onPressed: () {
                          if (titleController.text
                                  .trim()
                                  .isEmpty ||
                              amountController.text
                                  .trim()
                                  .isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter goal name and target amount',
                                ),
                              ),
                            );
                            return;
                          }

                          final targetAmount =
                              double.tryParse(
                                    amountController.text,
                                  ) ??
                                  0;

                          final currentAmount =
                              double.tryParse(
                                    savedController.text,
                                  ) ??
                                  0;

                          if (targetAmount <= 0) return;

                          final goal = FinancialGoal(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),

                            title:
                                titleController.text.trim(),

                            description:
                                descriptionController.text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : descriptionController
                                        .text
                                        .trim(),

                            targetAmount: targetAmount,

                            currentAmount: math.min(
                              currentAmount,
                              targetAmount,
                            ),

                            category: selectedCategory,

                            priority: selectedPriority,

                            createdDate: DateTime.now(),

                            targetDate: selectedDate,
                          );

                          context
                              .read<GoalProvider>()
                              .addGoal(goal);

                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Create Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
  // INPUT FIELD
  // ============================================================

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          color: Colors.white54,
        ),
        prefixIcon: Icon(
          icon,
          color: cyan,
        ),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryPurple,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADD MONEY
  // ============================================================

  void _showAddMoneySheet(FinancialGoal goal) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                    30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                'Add Money to ${goal.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              _inputField(
                controller: controller,
                label: 'Amount',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final amount =
                        double.tryParse(controller.text) ??
                            0;

                    if (amount <= 0) return;

                    context
                        .read<GoalProvider>()
                        .addMoneyToGoal(
                          goal.id,
                          amount,
                        );

                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Add Money',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
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
  // GOAL DETAILS
  // ============================================================

  void _showGoalDetails(FinancialGoal goal) {
    final color = _categoryColor(goal.category);

    showModalBottomSheet(
      context: context,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _categoryIcon(goal.category),
                  color: color,
                  size: 34,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                goal.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              if (goal.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  goal.description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _detailBox(
                      'Saved',
                      '₹${_formatAmount(goal.currentAmount)}',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _detailBox(
                      'Remaining',
                      '₹${_formatAmount(goal.remainingAmount)}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddMoneySheet(goal);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Money'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cyan,
                        side: const BorderSide(
                          color: cyan,
                        ),
                        minimumSize:
                            const Size.fromHeight(50),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  IconButton(
                    onPressed: () {
                      context
                          .read<GoalProvider>()
                          .deleteGoal(goal.id);

                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI INSIGHT
  // ============================================================

  void _showAIInsight(GoalProvider provider) {
    String message;

    if (provider.goals.isEmpty) {
      message =
          'Start by creating your first financial goal. Small consistent savings can create big results!';
    } else if (provider.overallProgress >= 0.75) {
      message =
          'Amazing progress! You are very close to achieving your financial goals. Keep your saving momentum strong.';
    } else if (provider.overallProgress >= 0.4) {
      message =
          'You are making steady progress. Consider automating monthly contributions to reach your goals faster.';
    } else {
      message =
          'Your goals need more momentum. Try setting aside a fixed percentage of your monthly income for savings.';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: cyan,
              ),
              SizedBox(width: 10),
              Text(
                'FinPilot AI Insight',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: primaryPurple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CATEGORY COLOR
  // ============================================================

  Color _categoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.emergency:
        return Colors.redAccent;

      case GoalCategory.travel:
        return Colors.orangeAccent;

      case GoalCategory.vehicle:
        return Colors.blueAccent;

      case GoalCategory.home:
        return Colors.purpleAccent;

      case GoalCategory.education:
        return Colors.greenAccent;

      case GoalCategory.investment:
        return Colors.tealAccent;

      case GoalCategory.gadget:
        return Colors.cyanAccent;

      case GoalCategory.wedding:
        return Colors.pinkAccent;

      case GoalCategory.purchase:
        return Colors.deepOrangeAccent;

      case GoalCategory.retirement:
        return Colors.amberAccent;

      case GoalCategory.other:
        return Colors.grey;
    }
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _categoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.emergency:
        return Icons.health_and_safety_rounded;

      case GoalCategory.travel:
        return Icons.flight_takeoff_rounded;

      case GoalCategory.vehicle:
        return Icons.directions_car_rounded;

      case GoalCategory.home:
        return Icons.home_rounded;

      case GoalCategory.education:
        return Icons.school_rounded;

      case GoalCategory.investment:
        return Icons.trending_up_rounded;

      case GoalCategory.gadget:
        return Icons.laptop_mac_rounded;

      case GoalCategory.wedding:
        return Icons.favorite_rounded;

      case GoalCategory.purchase:
        return Icons.shopping_bag_rounded;

      case GoalCategory.retirement:
        return Icons.elderly_rounded;

      case GoalCategory.other:
        return Icons.flag_rounded;
    }
  }

  // ============================================================
  // CATEGORY LABEL
  // ============================================================

  String _categoryLabel(GoalCategory category) {
    switch (category) {
      case GoalCategory.emergency:
        return 'Emergency';

      case GoalCategory.travel:
        return 'Travel';

      case GoalCategory.vehicle:
        return 'Vehicle';

      case GoalCategory.home:
        return 'Home';

      case GoalCategory.education:
        return 'Education';

      case GoalCategory.investment:
        return 'Investment';

      case GoalCategory.gadget:
        return 'Gadget';

      case GoalCategory.wedding:
        return 'Wedding';

      case GoalCategory.purchase:
        return 'Purchase';

      case GoalCategory.retirement:
        return 'Retirement';

      case GoalCategory.other:
        return 'Other';
    }
  }

  // ============================================================
  // FORMAT AMOUNT
  // ============================================================

  String _formatAmount(double amount) {
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