import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/finance_transaction.dart';
import '../services/storage_service.dart';

class BudgetProvider extends ChangeNotifier {
  double _monthlyBudget = 25000;

  final Map<String, double> _categoryBudgets = {
    'Food': 6000,
    'Transport': 3000,
    'Shopping': 4000,
    'Bills': 5000,
    'Entertainment': 2500,
    'Health': 2000,
    'Education': 1500,
    'Other': 1000,
  };

  BudgetProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final storage = await StorageService.getInstance();
      final savedBudgets = await storage.loadCategoryBudgets();
      final savedMonthly = await storage.loadMonthlyBudget();

      _monthlyBudget = savedMonthly;
      if (savedBudgets.isNotEmpty) {
        _categoryBudgets.clear();
        _categoryBudgets.addAll(savedBudgets);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('BudgetProvider load error: $e');
    }
  }

  Future<void> _persist() async {
    final storage = await StorageService.getInstance();
    await storage.saveCategoryBudgets(_categoryBudgets);
    await storage.saveMonthlyBudget(_monthlyBudget);
  }

  // ============================================================
  // MONTHLY BUDGET
  // ============================================================

  double get monthlyBudget => _monthlyBudget;

  Map<String, double> get categoryBudgets =>
      Map.unmodifiable(_categoryBudgets);

  List<BudgetModel> get budgets {
    return _categoryBudgets.entries.map((e) {
      return BudgetModel(
        id: e.key,
        category: e.key,
        limit: e.value,
        icon: 'category',
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  // ============================================================
  // SET MONTHLY BUDGET
  // ============================================================

  Future<void> setMonthlyBudget(double amount) async {
    if (amount < 0) return;
    _monthlyBudget = amount;
    notifyListeners();
    await _persist();
  }

  // ============================================================
  // UPDATE CATEGORY BUDGET
  // ============================================================

  Future<void> setCategoryBudget(String category, double amount) async {
    if (amount < 0) return;
    _categoryBudgets[category] = amount;
    notifyListeners();
    await _persist();
  }

  // ============================================================
  // ADD NEW CATEGORY
  // ============================================================

  Future<void> addCategory(String category, double budget) async {
    if (category.trim().isEmpty) return;
    _categoryBudgets[category] = budget;
    notifyListeners();
    await _persist();
  }

  // ============================================================
  // REMOVE CATEGORY
  // ============================================================

  Future<void> removeCategory(String category) async {
    _categoryBudgets.remove(category);
    notifyListeners();
    await _persist();
  }

  // ============================================================
  // RESET BUDGETS
  // ============================================================

  Future<void> resetBudgets() async {
    _monthlyBudget = 25000;
    _categoryBudgets.clear();
    _categoryBudgets.addAll({
      'Food': 6000,
      'Transport': 3000,
      'Shopping': 4000,
      'Bills': 5000,
      'Entertainment': 2500,
      'Health': 2000,
      'Education': 1500,
      'Other': 1000,
    });
    notifyListeners();
    await _persist();
  }

  // ============================================================
  // CALCULATIONS WITH TRANSACTIONS
  // ============================================================

  double totalExpense(List<FinanceTransaction> transactions) {
    return transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double remainingBudget(List<FinanceTransaction> transactions) {
    return _monthlyBudget - totalExpense(transactions);
  }

  double budgetPercentage(List<FinanceTransaction> transactions) {
    if (_monthlyBudget <= 0) return 0;
    return totalExpense(transactions) / _monthlyBudget;
  }

  double categorySpent(String category, List<FinanceTransaction> transactions) {
    return transactions
        .where((t) => !t.isIncome && t.category.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double categoryPercentage(String category, List<FinanceTransaction> transactions) {
    final budget = _categoryBudgets[category] ?? 0;
    if (budget <= 0) return 0;
    return categorySpent(category, transactions) / budget;
  }

  double categoryRemaining(String category, List<FinanceTransaction> transactions) {
    final budget = _categoryBudgets[category] ?? 0;
    return budget - categorySpent(category, transactions);
  }

  bool isOverBudget(List<FinanceTransaction> transactions) {
    return totalExpense(transactions) > _monthlyBudget;
  }

  bool isCategoryOverBudget(String category, List<FinanceTransaction> transactions) {
    final budget = _categoryBudgets[category] ?? 0;
    if (budget <= 0) return false;
    return categorySpent(category, transactions) > budget;
  }

  String budgetStatus(List<FinanceTransaction> transactions) {
    final percentage = budgetPercentage(transactions);
    if (percentage >= 1) return 'Over Budget';
    if (percentage >= 0.9) return 'Critical';
    if (percentage >= 0.75) return 'Warning';
    if (percentage >= 0.5) return 'Moderate';
    return 'Healthy';
  }

  String budgetMessage(List<FinanceTransaction> transactions) {
    final percentage = budgetPercentage(transactions);
    if (percentage >= 1) return 'You have exceeded your monthly budget.';
    if (percentage >= 0.9) return 'You are very close to your budget limit.';
    if (percentage >= 0.75) return 'Your spending is getting high this month.';
    if (percentage >= 0.5) return 'You are halfway through your monthly budget.';
    return 'Your spending is currently under control.';
  }

  List<String> overBudgetCategories(List<FinanceTransaction> transactions) {
    final List<String> cats = [];
    for (final category in _categoryBudgets.keys) {
      if (isCategoryOverBudget(category, transactions)) {
        cats.add(category);
      }
    }
    return cats;
  }

  List<String> warningCategories(List<FinanceTransaction> transactions) {
    final List<String> cats = [];
    for (final category in _categoryBudgets.keys) {
      final percentage = categoryPercentage(category, transactions);
      if (percentage >= 0.8 && percentage < 1) {
        cats.add(category);
      }
    }
    return cats;
  }

  List<String> get categories => _categoryBudgets.keys.toList();
}