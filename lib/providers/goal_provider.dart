import 'package:flutter/material.dart';
import '../models/financial_goal.dart';
import '../services/storage_service.dart';

class GoalProvider extends ChangeNotifier {
  final List<FinancialGoal> _goals = [];
  bool _isLoading = false;

  GoalProvider() {
    loadGoals();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  List<FinancialGoal> get goals => List.unmodifiable(_goals);

  bool get isLoading => _isLoading;

  List<FinancialGoal> get activeGoals {
    return _goals.where((goal) => !goal.isCompleted).toList();
  }

  List<FinancialGoal> get completedGoals {
    return _goals.where((goal) => goal.isCompleted).toList();
  }

  int get totalGoals => _goals.length;

  int get completedGoalsCount => completedGoals.length;

  double get totalTargetAmount {
    return _goals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.targetAmount,
    );
  }

  double get totalSavedAmount {
    return _goals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.currentAmount,
    );
  }

  double get overallProgress {
    if (totalTargetAmount <= 0) return 0.0;

    return (totalSavedAmount / totalTargetAmount)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  // ============================================================
  // LOAD GOALS FROM STORAGE
  // ============================================================

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storage = await StorageService.getInstance();
      final saved = await storage.loadGoals();
      _goals.clear();
      if (saved.isNotEmpty) {
        _goals.addAll(saved);
      } else {
        addDemoGoals();
      }
    } catch (e) {
      debugPrint('GoalProvider load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistGoals() async {
    final storage = await StorageService.getInstance();
    await storage.saveGoals(_goals);
  }

  // ============================================================
  // ADD GOAL
  // ============================================================

  Future<void> addGoal(FinancialGoal goal) async {
    final isCompleted = goal.currentAmount >= goal.targetAmount;

    _goals.add(
      goal.copyWith(
        isCompleted: isCompleted,
      ),
    );

    notifyListeners();
    await _persistGoals();
  }

  // ============================================================
  // UPDATE GOAL
  // ============================================================

  Future<void> updateGoal(FinancialGoal updatedGoal) async {
    final index = _goals.indexWhere(
      (goal) => goal.id == updatedGoal.id,
    );

    if (index == -1) return;

    final isCompleted =
        updatedGoal.currentAmount >= updatedGoal.targetAmount;

    _goals[index] = updatedGoal.copyWith(
      isCompleted: isCompleted,
    );

    notifyListeners();
    await _persistGoals();
  }

  // ============================================================
  // ADD MONEY TO GOAL
  // ============================================================

  Future<void> addMoneyToGoal(
    String goalId,
    double amount,
  ) async {
    if (amount <= 0) return;

    final index = _goals.indexWhere(
      (goal) => goal.id == goalId,
    );

    if (index == -1) return;

    final goal = _goals[index];

    final newAmount = (goal.currentAmount + amount)
        .clamp(0.0, goal.targetAmount)
        .toDouble();

    _goals[index] = goal.copyWith(
      currentAmount: newAmount,
      isCompleted: newAmount >= goal.targetAmount,
    );

    notifyListeners();
    await _persistGoals();
  }

  // ============================================================
  // REMOVE MONEY FROM GOAL
  // ============================================================

  Future<void> removeMoneyFromGoal(
    String goalId,
    double amount,
  ) async {
    if (amount <= 0) return;

    final index = _goals.indexWhere(
      (goal) => goal.id == goalId,
    );

    if (index == -1) return;

    final goal = _goals[index];

    final newAmount = (goal.currentAmount - amount)
        .clamp(0.0, goal.targetAmount)
        .toDouble();

    _goals[index] = goal.copyWith(
      currentAmount: newAmount,
      isCompleted: newAmount >= goal.targetAmount,
    );

    notifyListeners();
    await _persistGoals();
  }

  // ============================================================
  // MARK COMPLETED
  // ============================================================

  Future<void> markGoalCompleted(String goalId) async {
    final index = _goals.indexWhere(
      (goal) => goal.id == goalId,
    );

    if (index == -1) return;

    final goal = _goals[index];

    _goals[index] = goal.copyWith(
      currentAmount: goal.targetAmount,
      isCompleted: true,
    );

    notifyListeners();
    await _persistGoals();
  }

  // ============================================================
  // DELETE GOAL
  // ============================================================

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere(
      (goal) => goal.id == goalId,
    );

    notifyListeners();
    await _persistGoals();
  }

  // ============================================================
  // CLEAR GOALS
  // ============================================================

  Future<void> clearGoals() async {
    _goals.clear();
    notifyListeners();
    await _persistGoals();
  }

  // ============================================================
  // DEMO GOALS
  // ============================================================

  void addDemoGoals() {
    if (_goals.isNotEmpty) return;

    _goals.addAll([
      FinancialGoal(
        id: 'demo_emergency',
        title: 'Emergency Fund',
        description: 'Build a 3-month safety buffer',
        targetAmount: 100000,
        currentAmount: 35000,
        category: GoalCategory.emergency,
        priority: GoalPriority.high,
        createdDate: DateTime.now(),
        targetDate: DateTime.now().add(
          const Duration(days: 180),
        ),
        isCompleted: false,
      ),
      FinancialGoal(
        id: 'demo_car',
        title: 'Car Down Payment',
        description: 'Save 20% down payment for vehicle',
        targetAmount: 200000,
        currentAmount: 50000,
        category: GoalCategory.vehicle,
        priority: GoalPriority.high,
        createdDate: DateTime.now(),
        targetDate: DateTime.now().add(
          const Duration(days: 365),
        ),
        isCompleted: false,
      ),
    ]);

    notifyListeners();
  }
}