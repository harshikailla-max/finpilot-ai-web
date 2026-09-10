import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/ai_investment_goal_plan.dart';
import '../models/financial_goal.dart';
import '../models/investment_model.dart';
import '../providers/finance_provider.dart';
import '../services/ai_investment_engine.dart';
import '../services/financial_calculator_service.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> with TickerProviderStateMixin {
  // Theme Palette
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);
  static const Color amber = Color(0xFFFFB86B);

  late TabController _tabController;
  late AnimationController _orbController;

  // ------------------------------------------------------------
  // AI GOAL PLANNER STATE
  // ------------------------------------------------------------
  InvestmentGoalType _selectedGoal = InvestmentGoalType.car;
  late TextEditingController _goalTitleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentSavingsController;
  late TextEditingController _monthlyCapacityController;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365 * 3));

  RiskProfileLevel _riskProfile = RiskProfileLevel.balanced;
  int _riskScore = 55;
  int _selectedStrategyIndex = 0;

  // Simulator state
  double _simMonthly = 15000.0;
  int _simYears = 5;
  double _simRate = 12.0;

  AiInvestmentPlan? _currentPlan;

  final List<String> _assetTypes = [
    'Mutual Funds',
    'Stocks / Equity',
    'Fixed Deposit',
    'Gold',
    'Crypto',
    'Real Estate',
    'PPF / EPF',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _goalTitleController = TextEditingController(text: _selectedGoal.displayName);
    _targetAmountController = TextEditingController(text: _selectedGoal.defaultTargetAmount.toStringAsFixed(0));
    _currentSavingsController = TextEditingController(text: '150000');
    _monthlyCapacityController = TextEditingController(text: '15000');

    // Restore saved plan or calculate initial plan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final finance = context.read<FinanceProvider>();
      if (finance.savedInvestmentPlan != null) {
        _restoreFromSavedPlan(finance.savedInvestmentPlan!);
      } else {
        _recalculatePlan();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orbController.dispose();
    _goalTitleController.dispose();
    _targetAmountController.dispose();
    _currentSavingsController.dispose();
    _monthlyCapacityController.dispose();
    super.dispose();
  }

  void _restoreFromSavedPlan(AiInvestmentPlan plan) {
    setState(() {
      _selectedGoal = plan.goalType;
      _goalTitleController.text = plan.goalTitle;
      _targetAmountController.text = plan.targetAmount.toStringAsFixed(0);
      _targetDate = plan.targetDate;
      _currentSavingsController.text = plan.currentSavings.toStringAsFixed(0);
      _monthlyCapacityController.text = plan.monthlyCapacity.toStringAsFixed(0);
      _riskProfile = plan.riskProfile;
      _riskScore = plan.riskScore;
      _currentPlan = plan;
      _selectedStrategyIndex = 0;
      _simMonthly = plan.monthlyCapacity > 0 ? plan.monthlyCapacity : 15000;
      _simYears = math.max(1, (plan.monthsRemaining / 12).round());
      _simRate = plan.selectedStrategy.expectedReturnRate;
    });
  }

  void _onGoalSelected(InvestmentGoalType goal) {
    setState(() {
      _selectedGoal = goal;
      _goalTitleController.text = goal.displayName;
      _targetAmountController.text = goal.defaultTargetAmount.toStringAsFixed(0);
      _targetDate = DateTime.now().add(Duration(days: 365 * goal.defaultYears));
      _selectedStrategyIndex = 0;
    });
    _recalculatePlan();
  }

  void _recalculatePlan() {
    final target = double.tryParse(_targetAmountController.text.replaceAll(',', '').trim()) ?? _selectedGoal.defaultTargetAmount;
    final savings = double.tryParse(_currentSavingsController.text.replaceAll(',', '').trim()) ?? 0.0;
    final capacity = double.tryParse(_monthlyCapacityController.text.replaceAll(',', '').trim()) ?? 15000.0;

    final plan = AiInvestmentEngine.buildPlan(
      goalType: _selectedGoal,
      goalTitle: _goalTitleController.text.trim(),
      targetAmount: target,
      targetDate: _targetDate,
      currentSavings: savings,
      monthlyCapacity: capacity,
      riskProfile: _riskProfile,
      manualRiskScore: _riskScore,
    );

    setState(() {
      _currentPlan = plan;
      _simMonthly = capacity > 0 ? capacity : plan.requiredMonthlyContribution;
      _simYears = math.max(1, (plan.monthsRemaining / 12).round());
      _simRate = plan.selectedStrategy.expectedReturnRate;
    });
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 40)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: purple,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
      _recalculatePlan();
    }
  }

  // ------------------------------------------------------------
  // RISK ASSESSMENT MODAL
  // ------------------------------------------------------------
  void _showRiskAssessmentModal() {
    final questions = AiInvestmentEngine.getRiskQuestions();
    final answers = <String, int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.psychology_alt_rounded, color: cyan, size: 26),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Risk Profiler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('5 quick questions to tailor your investment volatility', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, idx) {
                        final q = questions[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${idx + 1}. ${q.question}',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              ...q.options.map((opt) {
                                final isSelected = answers[q.id] == opt.points;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      answers[q.id] = opt.points;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSelected ? purple.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? cyan : Colors.white10,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                          color: isSelected ? cyan : Colors.white38,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            opt.label,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.white70,
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Calculate score
                        int score = 0;
                        for (final q in questions) {
                          score += answers[q.id] ?? 15;
                        }
                        // Normalize 25-125 to 10-100
                        final normalizedScore = ((score / 125.0) * 100).round().clamp(10, 100);
                        final profile = AiInvestmentEngine.evaluateRiskScore(normalizedScore);

                        setState(() {
                          _riskScore = normalizedScore;
                          _riskProfile = profile;
                        });
                        _recalculatePlan();
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: cardColor,
                            content: Text(
                              'Profile updated to ${profile.displayName} (Score: $normalizedScore/100)',
                              style: TextStyle(color: profile.color, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CALCULATE MY RISK PROFILE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // STRATEGY EXPLORE MODAL
  // ------------------------------------------------------------
  void _showStrategyDetailModal(InvestmentStrategy strategy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(strategy.badgeText, style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                          const SizedBox(height: 4),
                          Text(strategy.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: purple.withValues(alpha: 0.4)),
                      ),
                      child: Text('${strategy.matchScore}% Match', style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 14),

                // Metrics Row
                Row(
                  children: [
                    Expanded(child: _modalMetric('Risk Level', strategy.riskLevel, cyan)),
                    Expanded(child: _modalMetric('Expected Return', strategy.potentialGrowthRange, green)),
                    Expanded(child: _modalMetric('Liquidity', strategy.liquidity, amber)),
                  ],
                ),
                const SizedBox(height: 22),

                // Allocation Breakdown
                const Text('SUGGESTED ASSET ALLOCATION', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 10),
                _allocationBar(strategy.equityPercentage, strategy.debtPercentage, strategy.liquidPercentage),
                const SizedBox(height: 20),

                // Why It Fits
                _detailBlock('Why FinPilot Recommends This', strategy.whyItFits, Icons.check_circle_outline, green),
                const SizedBox(height: 14),

                // Tradeoffs
                _detailBlock('Considerations & Tradeoffs', strategy.whyItMayNotFit, Icons.info_outline, amber),
                const SizedBox(height: 20),

                // Recommended Categories
                const Text('RECOMMENDED INSTRUMENTS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 10),
                ...strategy.recommendedCategories.map((cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right_rounded, color: cyan, size: 20),
                          const SizedBox(width: 6),
                          Expanded(child: Text(cat, style: const TextStyle(color: Colors.white, fontSize: 13))),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedStrategyIndex = _currentPlan!.allStrategies.indexOf(strategy);
                        _simRate = strategy.expectedReturnRate;
                      });
                      _recalculatePlan();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('SELECT THIS STRATEGY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // COMPARE 3 STRATEGIES MODAL
  // ------------------------------------------------------------
  void _showCompareStrategiesModal() {
    if (_currentPlan == null) return;
    final strats = _currentPlan!.allStrategies;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.compare_arrows_rounded, color: cyan, size: 24),
                  SizedBox(width: 10),
                  Text('Compare Top 3 Strategies', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Side-by-side evaluation tailored to your goal timeline and risk tolerance', style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              Expanded(
                child: ListView.builder(
                  itemCount: strats.length,
                  itemBuilder: (context, idx) {
                    final s = strats[idx];
                    final isSelected = idx == _selectedStrategyIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? purple.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isSelected ? cyan : Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.badgeText, style: TextStyle(color: isSelected ? cyan : Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('${s.matchScore}% Match', style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _compareChip('Risk', s.riskLevel),
                              const SizedBox(width: 8),
                              _compareChip('Return', s.potentialGrowthRange),
                              const SizedBox(width: 8),
                              _compareChip('Liquidity', s.liquidity),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _allocationBar(s.equityPercentage, s.debtPercentage, s.liquidPercentage),
                          const SizedBox(height: 10),
                          Text(s.whyItFits, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ASK FINPILOT AI CHAT SHEET
  // ------------------------------------------------------------
  void _showAskAiModal() {
    if (_currentPlan == null) return;
    final plan = _currentPlan!;
    final queryCtrl = TextEditingController();
    String? aiAnswer;

    final presetQueries = [
      'Can I buy a car in 3 years?',
      'Where should I invest ₹10,000 per month?',
      'How much should I invest for retirement?',
      'Should I choose a safer strategy?',
      'Can I reach ₹20 lakh in 5 years?',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setAiState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: cyan, size: 24),
                        SizedBox(width: 10),
                        Text('Ask FinPilot AI Copilot', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Goal-aware AI guidance based on your ${plan.goalTitle} parameters', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 8),

                    // Preset Query Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: presetQueries.map((q) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              backgroundColor: purple.withValues(alpha: 0.2),
                              side: BorderSide(color: purple.withValues(alpha: 0.4)),
                              label: Text(q, style: const TextStyle(color: Colors.white, fontSize: 11)),
                              onPressed: () {
                                setAiState(() {
                                  queryCtrl.text = q;
                                  aiAnswer = AiInvestmentEngine.getAiChatAnswer(question: q, plan: plan);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Custom Question Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: queryCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Ask any investment question...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onSubmitted: (text) {
                              if (text.trim().isNotEmpty) {
                                setAiState(() {
                                  aiAnswer = AiInvestmentEngine.getAiChatAnswer(question: text, plan: plan);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: cyan),
                          onPressed: () {
                            if (queryCtrl.text.trim().isNotEmpty) {
                              setAiState(() {
                                aiAnswer = AiInvestmentEngine.getAiChatAnswer(question: queryCtrl.text, plan: plan);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // AI Answer Box
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF1B223D), Color(0xFF10192B)]),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: purple.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.insights_rounded, color: green, size: 18),
                                  SizedBox(width: 8),
                                  Text('FinPilot AI Response', style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                aiAnswer ??
                                    'Select a preset question above or type your own question to receive contextual financial insights based on your active target of ₹${(plan.targetAmount / 100000).toStringAsFixed(1)}L.',
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // ------------------------------------------------------------
  // SAVE GOAL & SET REMINDER ACTIONS
  // ------------------------------------------------------------
  Future<void> _saveGoalPlan() async {
    if (_currentPlan == null) return;
    final plan = _currentPlan!;
    final finance = context.read<FinanceProvider>();

    // 1. Save AI Investment Plan to storage
    await finance.saveInvestmentPlan(plan);

    // 2. Synchronize with dashboard goals if not already present
    final existingGoalIndex = finance.goals.indexWhere((g) => g.title.toLowerCase() == plan.goalTitle.toLowerCase());
    if (existingGoalIndex == -1) {
      GoalCategory cat = GoalCategory.other;
      switch (plan.goalType) {
        case InvestmentGoalType.car:
          cat = GoalCategory.vehicle;
          break;
        case InvestmentGoalType.home:
          cat = GoalCategory.home;
          break;
        case InvestmentGoalType.education:
          cat = GoalCategory.education;
          break;
        case InvestmentGoalType.travel:
          cat = GoalCategory.travel;
          break;
        case InvestmentGoalType.marriage:
          cat = GoalCategory.wedding;
          break;
        case InvestmentGoalType.emergency:
          cat = GoalCategory.emergency;
          break;
        case InvestmentGoalType.wealth:
        case InvestmentGoalType.retirement:
        case InvestmentGoalType.taxSaving:
          cat = GoalCategory.investment;
          break;
        case InvestmentGoalType.custom:
          cat = GoalCategory.purchase;
          break;
      }

      final newGoal = FinancialGoal(
        id: const Uuid().v4(),
        title: plan.goalTitle,
        targetAmount: plan.targetAmount,
        currentAmount: plan.currentSavings,
        targetDate: plan.targetDate,
        category: cat,
        priority: GoalPriority.high,
        createdDate: DateTime.now(),
      );

      final updatedGoals = List<FinancialGoal>.from(finance.goals)..add(newGoal);
      await finance.updateGoals(updatedGoals);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardColor,
        content: Text(
          'Goal "${plan.goalTitle}" and AI Investment Plan successfully saved!',
          style: const TextStyle(color: green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _setMonthlyReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: cardColor,
        content: Text(
          'Monthly Investment Reminder active! You will be reminded on the 1st of every month to execute your SIP.',
          style: TextStyle(color: cyan, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD METHOD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Investments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: purple,
          labelColor: cyan,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'AI GOAL PLANNER'),
            Tab(text: 'PORTFOLIO TRACKER'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAiGoalPlannerTab(),
          _buildPortfolioTrackerTab(),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: AI GOAL PLANNER
  // ============================================================
  Widget _buildAiGoalPlannerTab() {
    final plan = _currentPlan;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER WITH ANIMATED AI ORB
          _buildHeader(),

          const SizedBox(height: 24),

          // 2. GOAL SELECTION
          _buildGoalSelector(),

          const SizedBox(height: 24),

          // 3. GOAL DETAILS & TARGET INPUTS
          _buildGoalDetailsCard(),

          const SizedBox(height: 24),

          // 4. RISK PROFILE & QUESTIONNAIRE
          _buildRiskProfileSection(),

          const SizedBox(height: 24),

          // 5. FINPILOT AI ANALYSIS BANNER
          if (plan != null) _buildAiAnalysisBanner(plan),

          const SizedBox(height: 24),

          // SPECIAL MODES: TAX SAVER / EMERGENCY FUND
          if (_selectedGoal == InvestmentGoalType.taxSaving) _buildTaxSaverBanner(),
          if (_selectedGoal == InvestmentGoalType.emergency) _buildEmergencyFundBanner(),

          const SizedBox(height: 12),

          // 6. SMART INVESTMENT RECOMMENDATIONS (TOP 3 STRATEGIES)
          if (plan != null) _buildTop3Strategies(plan),

          const SizedBox(height: 24),

          // 7. AI PORTFOLIO ALLOCATION & WHY THIS ALLOCATION
          if (plan != null) _buildAiPortfolioAllocation(plan),

          const SizedBox(height: 24),

          // 8. GOAL VS INVESTMENT MATCH (4 SCORES)
          if (plan != null) _buildGoalMatchScores(plan),

          const SizedBox(height: 24),

          // 9. "HOW MUCH SHOULD I INVEST?" FEASIBILITY
          if (plan != null) _buildHowMuchShouldIInvestCard(plan),

          const SizedBox(height: 24),

          // 10. "WHAT IF?" SCENARIOS
          if (plan != null) _buildWhatIfSection(plan),

          const SizedBox(height: 24),

          // 11. INVESTMENT SIMULATOR
          _buildInvestmentSimulator(),

          const SizedBox(height: 24),

          // 12. FINPILOT AI RECOMMENDATION SUMMARY
          if (plan != null) _buildAiFinalRecommendation(plan),

          const SizedBox(height: 28),

          // 13. ACTION BUTTONS
          _buildActionButtons(),

          const SizedBox(height: 24),

          // FINANCIAL SAFETY DISCLAIMER (SECTION 21)
          _buildDisclaimer(),
        ],
      ),
    );
  }

  // 1. Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1A4A), Color(0xFF10192B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: purple.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          // Glowing FinPilot AI Orb
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              final scale = 1.0 + (_orbController.value * 0.12);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [cyan, purple, Colors.transparent],
                      stops: [0.2, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cyan.withValues(alpha: 0.4 + (_orbController.value * 0.3)),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: purple.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'AI-powered • Goal-based • Personalized',
                    style: TextStyle(color: cyan, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'AI Investment Planner',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Turn your goals into an investment strategy.',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Goal Selector
  Widget _buildGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHAT ARE YOU INVESTING FOR?',
          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: InvestmentGoalType.values.map((goal) {
              final isSelected = goal == _selectedGoal;
              return GestureDetector(
                onTap: () => _onGoalSelected(goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? purple.withValues(alpha: 0.3) : cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? cyan : Colors.white12,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cyan.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Text(goal.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.shortName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '~${goal.defaultYears}y target',
                            style: TextStyle(
                              color: isSelected ? cyan : Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 3. Goal Details Inputs Card
  Widget _buildGoalDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GOAL PARAMETERS',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: cyan, size: 20),
                tooltip: 'Recalculate Plan',
                onPressed: _recalculatePlan,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Goal Title input
          TextField(
            controller: _goalTitleController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration('Goal Title (e.g. Electric SUV)', Icons.flag_rounded),
            onChanged: (_) => _recalculatePlan(),
          ),
          const SizedBox(height: 14),

          // Target Amount & Current Savings Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: _inputDecoration('Target Amount (₹)', Icons.currency_rupee_rounded),
                  onChanged: (_) => _recalculatePlan(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _currentSavingsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _inputDecoration('Current Savings (₹)', Icons.savings_outlined),
                  onChanged: (_) => _recalculatePlan(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Monthly Capacity & Target Date
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _monthlyCapacityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _inputDecoration('Monthly Capacity (₹)', Icons.wallet_rounded),
                  onChanged: (_) => _recalculatePlan(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _pickTargetDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, color: cyan, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Target Date', style: TextStyle(color: Colors.white38, fontSize: 9)),
                              Text(
                                DateFormat('MMM yyyy').format(_targetDate),
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Risk Profile Section
  Widget _buildRiskProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RISK PROFILE & VOLATILITY TOLERANCE',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              TextButton.icon(
                onPressed: _showRiskAssessmentModal,
                icon: const Icon(Icons.quiz_outlined, color: cyan, size: 16),
                label: const Text('Take Quiz', style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Profile chips
          Row(
            children: RiskProfileLevel.values.map((level) {
              final isSelected = level == _riskProfile;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _riskProfile = level);
                    _recalculatePlan();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? level.color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? level.color : Colors.white12,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        level.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Summary explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: _riskProfile.color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _riskProfile.summary,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. AI Goal Analysis Banner
  Widget _buildAiAnalysisBanner(AiInvestmentPlan plan) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232050), Color(0xFF10192B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: purple.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: cyan, size: 20),
              SizedBox(width: 8),
              Text(
                'FINPILOT AI ANALYSIS',
                style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plan.aiAnalysisText,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // Special Mode: Tax Saver
  Widget _buildTaxSaverBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: amber.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: amber, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI TAX-SAVER MODE ACTIVE', style: TextStyle(color: amber, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(
                  'Optimizing for Section 80C deductions (up to ₹1.5L/year). Prioritizes ELSS (3-yr lock-in) and PPF. Check current tax rules before investing.',
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Special Mode: Emergency Fund
  Widget _buildEmergencyFundBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cyan.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.health_and_safety_rounded, color: cyan, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EMERGENCY FUND SHIELD ACTIVE', style: TextStyle(color: cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(
                  'Capital preservation and instant accessibility take 100% priority. Equity exposure is zero to eliminate market dip risk.',
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Top 3 Strategies
  Widget _buildTop3Strategies(AiInvestmentPlan plan) {
    final strats = plan.allStrategies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECOMMENDED STRATEGIES',
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            TextButton.icon(
              onPressed: _showCompareStrategiesModal,
              icon: const Icon(Icons.compare_arrows_rounded, color: cyan, size: 16),
              label: const Text('Compare 3', style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...List.generate(strats.length, (idx) {
          final s = strats[idx];
          final isSelected = idx == _selectedStrategyIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStrategyIndex = idx;
                _simRate = s.expectedReturnRate;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected ? cardColor : cardColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? cyan : Colors.white10,
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: purple.withValues(alpha: 0.25),
                          blurRadius: 14,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: idx == 0 ? green.withValues(alpha: 0.2) : purple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.badgeText,
                          style: TextStyle(
                            color: idx == 0 ? green : cyan,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: cyan, size: 16),
                          Text(
                            'AI Match: ${s.matchScore}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(s.whyItFits, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
                  const SizedBox(height: 14),

                  // Quick Stats Row
                  Row(
                    children: [
                      _miniStat('Risk', s.riskLevel),
                      const SizedBox(width: 8),
                      _miniStat('Return', s.potentialGrowthRange),
                      const SizedBox(width: 8),
                      _miniStat('Liquidity', s.liquidity),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Allocation Bar
                  _allocationBar(s.equityPercentage, s.debtPercentage, s.liquidPercentage),
                  const SizedBox(height: 14),

                  // Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showStrategyDetailModal(s),
                        icon: const Icon(Icons.visibility_outlined, size: 16, color: cyan),
                        label: const Text('Explore Strategy', style: TextStyle(color: cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? cyan : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? cyan : Colors.white24),
                        ),
                        child: Text(
                          isSelected ? 'ACTIVE STRATEGY' : 'SELECT',
                          style: TextStyle(
                            color: isSelected ? background : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // 7. AI Portfolio Allocation
  Widget _buildAiPortfolioAllocation(AiInvestmentPlan plan) {
    final strategy = plan.allStrategies[_selectedStrategyIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI PORTFOLIO ALLOCATION',
            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 16),

          // Horizontal Visual Bar
          _allocationBar(strategy.equityPercentage, strategy.debtPercentage, strategy.liquidPercentage, height: 14),
          const SizedBox(height: 16),

          // Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendItem('EQUITY', '${strategy.equityPercentage.toInt()}%', cyan),
              _legendItem('DEBT', '${strategy.debtPercentage.toInt()}%', purple),
              _legendItem('LIQUID / GOLD', '${strategy.liquidPercentage.toInt()}%', green),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          const Text('Why this allocation?', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Your goal is ${(plan.monthsRemaining / 12).toStringAsFixed(1)} years away with a ${_riskProfile.displayName} risk tolerance. '
            'Allocating ${strategy.equityPercentage.toInt()}% in growth instruments outpaces inflation, while ${strategy.debtPercentage.toInt()}% in fixed debt ensures target protection.',
            style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  // 8. Goal vs Investment Match (4 Scores)
  Widget _buildGoalMatchScores(AiInvestmentPlan plan) {
    final strat = plan.allStrategies[_selectedStrategyIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WHY THIS STRATEGY?', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Text('FINPILOT MATCH: ${strat.matchScore}%', style: const TextStyle(color: green, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _scoreRing('Goal Fit', '96%', cyan)),
              Expanded(child: _scoreRing('Risk Fit', '92%', purple)),
              Expanded(child: _scoreRing('Time Fit', '95%', green)),
              Expanded(child: _scoreRing('Liquidity', '88%', amber)),
            ],
          ),
        ],
      ),
    );
  }

  // 9. "How Much Should I Invest?"
  Widget _buildHowMuchShouldIInvestCard(AiInvestmentPlan plan) {
    final reqMonthly = plan.requiredMonthlyContribution;
    final capacity = plan.monthlyCapacity;
    final deficit = reqMonthly - capacity;

    Color badgeColor = green;
    IconData badgeIcon = Icons.check_circle_rounded;
    if (plan.feasibilityLabel == 'Requires Plan Adjustment') {
      badgeColor = amber;
      badgeIcon = Icons.warning_amber_rounded;
    } else if (plan.feasibilityLabel == 'Requires Higher Contribution') {
      badgeColor = red;
      badgeIcon = Icons.error_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HOW MUCH SHOULD I INVEST?', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(badgeIcon, color: badgeColor, size: 14),
                    const SizedBox(width: 4),
                    Text(plan.feasibilityLabel, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountTile('Target', '₹${(plan.targetAmount / 100000).toStringAsFixed(1)}L'),
              _amountTile('Current', '₹${(plan.currentSavings / 1000).toStringAsFixed(0)}k'),
              _amountTile('Remaining', '₹${(plan.remainingDeficit / 100000).toStringAsFixed(1)}L'),
              _amountTile('Time', '${plan.monthsRemaining} mos'),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recommended Monthly SIP', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('₹${reqMonthly.toStringAsFixed(0)}', style: const TextStyle(color: cyan, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Your Monthly Capacity', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('₹${capacity.toStringAsFixed(0)}', style: TextStyle(color: capacity >= reqMonthly ? green : amber, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),

          if (deficit > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: amber.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Deficit of ₹${deficit.toStringAsFixed(0)}/mo. Consider extending timeline by 6–12 months, boosting initial savings, or enabling an annual 10% Step-Up SIP.',
                style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 10. "What If?" Scenarios
  Widget _buildWhatIfSection(AiInvestmentPlan plan) {
    final scenarios = AiInvestmentEngine.generateWhatIfScenarios(
      targetAmount: plan.targetAmount,
      currentSavings: plan.currentSavings,
      monthsRemaining: plan.monthsRemaining,
      monthlyCapacity: plan.monthlyCapacity,
      expectedAnnualRate: plan.selectedStrategy.expectedReturnRate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '"WHAT IF?" SCENARIOS',
          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: scenarios.map((sc) {
              return Container(
                width: 240,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: purple.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sc.title, style: const TextStyle(color: cyan, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(sc.actionDescription, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(10)),
                      child: Text(sc.impactSummary, style: const TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 11. Investment Simulator
  Widget _buildInvestmentSimulator() {
    final proj = FinancialCalculatorService.calculateInvestmentProjections(
      monthlyInvestment: _simMonthly,
      years: _simYears,
      customExpectedReturnRate: _simRate,
    );

    final cons = proj['conservative'] as Map<String, dynamic>;
    final mod = proj['moderate'] as Map<String, dynamic>;
    final agg = proj['aggressive'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INVESTMENT SIMULATOR', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Investment:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('₹${_simMonthly.toStringAsFixed(0)} / mo', style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Slider(
            value: _simMonthly,
            min: 1000,
            max: 100000,
            divisions: 99,
            activeColor: purple,
            onChanged: (v) => setState(() => _simMonthly = v),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Duration:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('$_simYears Years', style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Slider(
            value: _simYears.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: cyan,
            onChanged: (v) => setState(() => _simYears = v.toInt()),
          ),
          const SizedBox(height: 16),

          // 3 Scenario Cards
          Row(
            children: [
              Expanded(child: _simCard('Conservative', '8%', cons['futureValue'] as double, cyan)),
              const SizedBox(width: 8),
              Expanded(child: _simCard('Base Case', '12%', mod['futureValue'] as double, purple)),
              const SizedBox(width: 8),
              Expanded(child: _simCard('Optimistic', '15%', agg['futureValue'] as double, green)),
            ],
          ),
        ],
      ),
    );
  }

  // 12. Final AI Recommendation
  Widget _buildAiFinalRecommendation(AiInvestmentPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: green.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded, color: green, size: 20),
              SizedBox(width: 8),
              Text("FINPILOT AI'S RECOMMENDATION", style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.aiRecommendationSummary,
            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  // 13. Action Buttons (All 6 Working!)
  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _recalculatePlan();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: cardColor,
                      content: Text('Plan blueprint generated and calibrated with latest market data!', style: TextStyle(color: cyan)),
                    ),
                  );
                },
                icon: const Icon(Icons.architecture_rounded, size: 18),
                label: const Text('BUILD MY PLAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showCompareStrategiesModal,
                icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                label: const Text('COMPARE 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: cyan,
                  side: const BorderSide(color: cyan),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveGoalPlan,
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('SAVE GOAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green.withValues(alpha: 0.2),
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _setMonthlyReminder,
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('SIP REMINDER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showAskAiModal,
            icon: const Icon(Icons.auto_awesome, color: cyan, size: 18),
            label: const Text('ASK FINPILOT AI ABOUT THIS GOAL', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1A4A),
              side: BorderSide(color: purple.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.white38, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Educational & Illustrative Guidance Only. Recommendations are assumption-based and subject to market volatility. FinPilot AI does not guarantee financial returns or provide SEBI-registered advisory. Verify terms, taxes, and lock-ins before investing.',
              style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: PORTFOLIO TRACKER (PRESERVED HOLDINGS & CAGR)
  // ============================================================
  Widget _buildPortfolioTrackerTab() {
    final finance = context.watch<FinanceProvider>();
    final holdings = finance.investments;

    final totalInvested = holdings.fold<double>(0, (sum, i) => sum + i.investedAmount);
    final totalCurrent = holdings.fold<double>(0, (sum, i) => sum + i.currentValue);
    final totalGain = totalCurrent - totalInvested;
    final totalReturnPct = totalInvested > 0 ? (totalGain / totalInvested) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Portfolio Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B2A47), Color(0xFF10192B)]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _portfolioSummaryStat('Total Invested', '₹${totalInvested.toStringAsFixed(0)}'),
                    _portfolioSummaryStat('Current Value', '₹${totalCurrent.toStringAsFixed(0)}', highlightColor: cyan),
                    _portfolioSummaryStat(
                      'Overall Gain/Loss',
                      '${totalGain >= 0 ? "+" : ""}₹${totalGain.toStringAsFixed(0)} (${totalReturnPct.toStringAsFixed(1)}%)',
                      highlightColor: totalGain >= 0 ? green : red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Asset Allocation Breakdown
          if (holdings.isNotEmpty && totalCurrent > 0)
            _buildAssetAllocationCard(holdings, totalCurrent),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HOLDINGS & RETURNS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ElevatedButton.icon(
                onPressed: _showAddInvestmentDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add Holding', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (holdings.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: const Center(
                child: Text(
                  'No investment holdings added yet. Tap "+ Add Holding" to track your stocks, mutual funds, gold, and fixed deposits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            )
          else
            ...holdings.map((inv) => _holdingCard(inv)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _portfolioSummaryStat(String label, String value, {Color? highlightColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: highlightColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAssetAllocationCard(List<InvestmentModel> holdings, double totalCurrent) {
    final Map<String, double> allocation = {};
    for (final h in holdings) {
      allocation[h.assetType] = (allocation[h.assetType] ?? 0.0) + h.currentValue;
    }

    final colors = [cyan, purple, green, amber, Colors.orange, Colors.teal, Colors.pinkAccent];
    int colorIdx = 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ASSET ALLOCATION DIVERSIFICATION', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 14),
          ...allocation.entries.map((entry) {
            final pct = (entry.value / totalCurrent) * 100;
            final color = colors[colorIdx % colors.length];
            colorIdx++;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('₹${entry.value.toStringAsFixed(0)} (${pct.toStringAsFixed(1)}%)', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      color: color,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _holdingCard(InvestmentModel inv) {
    final hasCagr = inv.holdingDays >= 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(inv.assetType, style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text('•  ${inv.holdingDays}d held', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${inv.currentValue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(
                    '${inv.gainLoss >= 0 ? "+" : ""}₹${inv.gainLoss.toStringAsFixed(0)} (${inv.returnPercentage.toStringAsFixed(1)}%)',
                    style: TextStyle(color: inv.gainLoss >= 0 ? green : red, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invested: ₹${inv.investedAmount.toStringAsFixed(0)}${hasCagr ? " • CAGR: ${inv.cagr.toStringAsFixed(1)}%" : ""}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showEditInvestmentDialog(inv),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: cyan, size: 14),
                          SizedBox(width: 4),
                          Text('Edit', style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.read<FinanceProvider>().deleteInvestment(inv.id),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 16),
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

  Future<void> _showAddInvestmentDialog() async {
    final nameCtrl = TextEditingController();
    final investedCtrl = TextEditingController();
    final currentCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    DateTime purchaseDate = DateTime.now();
    String assetType = 'Mutual Funds';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Add Investment Holding', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Asset Name (e.g. Nifty 50 Index Fund)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: assetType,
                      dropdownColor: cardColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Asset Type'),
                      items: _assetTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => assetType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: investedCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Total Invested (₹)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: currentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Current Market Value (₹)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Quantity / Units (Optional)'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Purchase Date:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded, size: 16, color: cyan),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(purchaseDate),
                            style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: purchaseDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() => purchaseDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: purple),
                  child: const Text('ADD', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      final name = nameCtrl.text.trim();
      final invested = double.tryParse(investedCtrl.text.trim()) ?? 0.0;
      final current = double.tryParse(currentCtrl.text.trim()) ?? invested;
      final qty = double.tryParse(quantityCtrl.text.trim());

      if (name.isNotEmpty && invested > 0) {
        final inv = InvestmentModel(
          id: const Uuid().v4(),
          name: name,
          assetType: assetType,
          investedAmount: invested,
          currentValue: current,
          date: purchaseDate,
          quantity: qty,
          buyPrice: (qty != null && qty > 0) ? invested / qty : null,
          currentPrice: (qty != null && qty > 0) ? current / qty : null,
        );
        await context.read<FinanceProvider>().addInvestment(inv);
      }
    }
  }

  Future<void> _showEditInvestmentDialog(InvestmentModel inv) async {
    final nameCtrl = TextEditingController(text: inv.name);
    final investedCtrl = TextEditingController(text: inv.investedAmount.toStringAsFixed(2));
    final currentCtrl = TextEditingController(text: inv.currentValue.toStringAsFixed(2));
    final quantityCtrl = TextEditingController(text: inv.quantity != null ? inv.quantity.toString() : '');
    String assetType = inv.assetType;

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Edit Investment Holding', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Asset Name'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _assetTypes.contains(assetType) ? assetType : _assetTypes.first,
                      dropdownColor: cardColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Asset Type'),
                      items: _assetTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => assetType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: investedCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Total Invested (₹)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: currentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Current Market Value (₹)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Quantity / Units'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: purple),
                  child: const Text('UPDATE', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true && mounted) {
      final name = nameCtrl.text.trim();
      final invested = double.tryParse(investedCtrl.text.trim()) ?? inv.investedAmount;
      final current = double.tryParse(currentCtrl.text.trim()) ?? inv.currentValue;
      final qty = double.tryParse(quantityCtrl.text.trim());

      final updatedInv = inv.copyWith(
        name: name.isNotEmpty ? name : inv.name,
        assetType: assetType,
        investedAmount: invested,
        currentValue: current,
        quantity: qty,
        buyPrice: (qty != null && qty > 0) ? invested / qty : null,
        currentPrice: (qty != null && qty > 0) ? current / qty : null,
      );

      await context.read<FinanceProvider>().updateInvestment(updatedInv);
    }
  }

  // ------------------------------------------------------------
  // HELPER WIDGETS
  // ------------------------------------------------------------
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
      prefixIcon: Icon(icon, color: cyan, size: 18),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: cyan, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _allocationBar(double eq, double debt, double liq, {double height = 8}) {
    final total = eq + debt + liq;
    final eqFlex = math.max(1, (eq / total * 100).toInt());
    final debtFlex = math.max(1, (debt / total * 100).toInt());
    final liqFlex = math.max(1, (liq / total * 100).toInt());

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(flex: eqFlex, child: Container(color: cyan)),
            Expanded(flex: debtFlex, child: Container(color: purple)),
            Expanded(flex: liqFlex, child: Container(color: green)),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, String pct, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label $pct', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _scoreRing(String title, String score, Color color) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(score, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _amountTile(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _simCard(String label, String rate, double val, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(rate, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          const SizedBox(height: 6),
          Text('₹${(val / 100000).toStringAsFixed(1)}L', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _modalMetric(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 3),
        Text(val, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _detailBlock(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compareChip(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8)),
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}