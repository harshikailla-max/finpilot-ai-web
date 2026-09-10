
import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';
import '../models/investment_model.dart';
import '../models/debt_model.dart';
import '../models/ai_investment_goal_plan.dart';
import '../services/storage_service.dart';
import '../services/financial_calculator_service.dart';

class FinanceProvider extends ChangeNotifier {
  final List<FinanceTransaction> _transactions = [];
  final List<FinancialGoal> _goals = [];
  final List<InvestmentModel> _investments = [];
  final List<DebtModel> _debts = [];
  AiInvestmentPlan? _savedInvestmentPlan;

  double _monthlyBudget = 25000;
  double _startingBalance = 48500;
  bool _isInitialized = false;

  FinanceProvider() {
    _initFromStorage();
  }

  bool get isInitialized => _isInitialized;
  AiInvestmentPlan? get savedInvestmentPlan => _savedInvestmentPlan;

  // ============================================================
  // INITIALIZATION FROM STORAGE
  // ============================================================

  Future<void> _initFromStorage() async {
    try {
      final storage = await StorageService.getInstance();
      final savedTx = await storage.loadTransactions();
      final savedGoals = await storage.loadGoals();
      final savedBudget = await storage.loadMonthlyBudget();
      final savedStartingBalance = await storage.loadStartingBalance();
      final savedInvestments = await storage.loadInvestments();
      final savedDebts = await storage.loadDebts();
      final savedPlan = await storage.loadSavedInvestmentPlan();

      _monthlyBudget = savedBudget;
      _startingBalance = savedStartingBalance;
      _savedInvestmentPlan = savedPlan;

      _goals.clear();
      _goals.addAll(savedGoals);

      _investments.clear();
      _investments.addAll(savedInvestments);

      _debts.clear();
      _debts.addAll(savedDebts);

      _transactions.clear();
      if (savedTx.isNotEmpty) {
        _transactions.addAll(savedTx);
      } else {
        // Initial starter seed so user sees functional dashboard on first run
        _transactions.addAll([
          FinanceTransaction(
            id: '1',
            title: 'Monthly Salary',
            amount: 65000,
            type: 'income',
            category: 'Salary',
            paymentMethod: 'Bank',
            date: DateTime.now().subtract(const Duration(days: 2)),
            description: 'Monthly salary credited',
            source: 'manual',
          ),
          FinanceTransaction(
            id: '2',
            title: 'Swiggy Order',
            amount: 450,
            type: 'expense',
            category: 'Food',
            paymentMethod: 'UPI',
            date: DateTime.now().subtract(const Duration(days: 1)),
            description: 'Dinner order',
            source: 'manual',
          ),
          FinanceTransaction(
            id: '3',
            title: 'Uber Ride',
            amount: 280,
            type: 'expense',
            category: 'Transport',
            paymentMethod: 'UPI',
            date: DateTime.now(),
            description: 'Office travel',
            source: 'manual',
          ),
          FinanceTransaction(
            id: '4',
            title: 'Netflix Subscription',
            amount: 649,
            type: 'expense',
            category: 'Entertainment',
            paymentMethod: 'Card',
            date: DateTime.now().subtract(const Duration(days: 3)),
            description: 'Monthly subscription',
            source: 'manual',
          ),
          FinanceTransaction(
            id: '5',
            title: 'Freelance Project',
            amount: 12000,
            type: 'income',
            category: 'Freelance',
            paymentMethod: 'Bank',
            date: DateTime.now().subtract(const Duration(days: 5)),
            description: 'Website project payment',
            source: 'manual',
          ),
        ]);
        await storage.saveTransactions(_transactions);
      }
    } catch (e) {
      debugPrint('FinanceProvider init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================

  List<FinanceTransaction> get transactions {
    final list = List<FinanceTransaction>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  double get monthlyBudget => _monthlyBudget;
  double get startingBalance => _startingBalance;
  String get userName => 'Harshika';

  List<FinancialGoal> get goals => List.unmodifiable(_goals);
  List<InvestmentModel> get investments => List.unmodifiable(_investments);
  List<DebtModel> get debts => List.unmodifiable(_debts);

  double get totalInvested =>
      _investments.fold<double>(0.0, (sum, i) => sum + i.investedAmount);

  double get totalPortfolioValue =>
      _investments.fold<double>(0.0, (sum, i) => sum + i.currentValue);

  double get portfolioReturnPercentage {
    if (totalInvested <= 0) return 0.0;
    return ((totalPortfolioValue - totalInvested) / totalInvested) * 100;
  }

  // ============================================================
  // TOTAL FINANCIAL METRICS
  // ============================================================

  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => !t.isIncome)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses => totalExpense;

  double get balance {
    return _startingBalance + totalIncome - totalExpense;
  }

  double get savings => totalIncome - totalExpense;

  // ============================================================
  // MONTHLY FINANCIAL METRICS
  // ============================================================

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  List<FinanceTransaction> get currentMonthTransactions {
    return _transactions.where((t) => _isCurrentMonth(t.date)).toList();
  }

  double get monthlyIncome {
    return _transactions
        .where((t) => t.isIncome && _isCurrentMonth(t.date))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    return _transactions
        .where((t) => !t.isIncome && _isCurrentMonth(t.date))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpenses => monthlyExpense;

  double get monthlySavings => monthlyIncome - monthlyExpense;

  double get savingsRate {
    if (monthlyIncome <= 0) return 0.0;
    return (monthlySavings / monthlyIncome * 100).clamp(0.0, 100.0);
  }

  double get remainingBudget => _monthlyBudget - monthlyExpense;

  double get budgetPercentage {
    if (_monthlyBudget <= 0) return 0.0;
    return (monthlyExpense / _monthlyBudget).clamp(0.0, 1.0);
  }

  bool get isOverBudget => monthlyExpense > _monthlyBudget;

  // ============================================================
  // CATEGORY BREAKDOWN
  // ============================================================

  Map<String, double> get categoryBreakdown {
    final Map<String, double> map = {};
    for (final t in _transactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0.0) + t.amount;
    }
    return map;
  }

  // ============================================================
  // FINANCIAL HEALTH
  // ============================================================

  Map<String, dynamic> get financialHealth {
    final totalDebtEmi = _debts.fold<double>(0.0, (sum, d) => sum + d.emi);
    return FinancialCalculatorService.calculateFinancialHealth(
      monthlyIncome: monthlyIncome > 0 ? monthlyIncome : totalIncome,
      monthlyExpenses: monthlyExpenses > 0 ? monthlyExpenses : totalExpense,
      currentBalance: balance,
      totalDebtEmi: totalDebtEmi,
      goals: _goals,
    );
  }

  // ============================================================
  // TRANSACTION COUNTS & HELPERS
  // ============================================================

  int get totalTransactions => _transactions.length;

  int get incomeTransactionsCount =>
      _transactions.where((t) => t.isIncome).length;

  int get expenseTransactionsCount =>
      _transactions.where((t) => !t.isIncome).length;

  List<FinanceTransaction> get expenseTransactions =>
      transactions.where((t) => !t.isIncome).toList();

  List<FinanceTransaction> get incomeTransactions =>
      transactions.where((t) => t.isIncome).toList();

  List<FinanceTransaction> get recentTransactions =>
      transactions.take(5).toList();

  double expenseByCategory(String category) {
    return _transactions
        .where((t) => !t.isIncome && t.category.toLowerCase() == category.toLowerCase())
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double incomeByCategory(String category) {
    return _transactions
        .where((t) => t.isIncome && t.category.toLowerCase() == category.toLowerCase())
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  // ============================================================
  // MUTATIONS (AUTO-PERSISTED)
  // ============================================================

  Future<void> addTransaction(FinanceTransaction transaction) async {
    _transactions.add(transaction);
    notifyListeners();
    _persistTransactions();
  }

  Future<void> addIncome({
    required String title,
    required double amount,
    required String category,
    required String paymentMethod,
    DateTime? date,
    String? note,
  }) async {
    final transaction = FinanceTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      date: date ?? DateTime.now(),
      type: 'income',
      description: note,
      source: 'manual',
    );
    await addTransaction(transaction);
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String paymentMethod,
    DateTime? date,
    String? note,
  }) async {
    final transaction = FinanceTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      date: date ?? DateTime.now(),
      type: 'expense',
      description: note,
      source: 'manual',
    );
    await addTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    _persistTransactions();
  }

  Future<void> updateTransaction(String id, FinanceTransaction updated) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _transactions[index] = updated;
    notifyListeners();
    _persistTransactions();
  }

  /// Batch imports transactions (e.g. from bank statement)
  Future<void> importTransactions(List<FinanceTransaction> importedList) async {
    _transactions.addAll(importedList);
    notifyListeners();
    await _persistTransactions();
  }

  Future<void> clearTransactions() async {
    _transactions.clear();
    notifyListeners();
    await _persistTransactions();
  }

  Future<void> deleteImportedTransactions() async {
    _transactions.removeWhere((t) => t.isImported || t.source == 'bank_statement');
    notifyListeners();
    await _persistTransactions();
  }

  Future<void> _persistTransactions() async {
    final storage = await StorageService.getInstance();
    await storage.saveTransactions(_transactions);
  }

  // ============================================================
  // BUDGET & SETTINGS MUTATIONS
  // ============================================================

  Future<void> updateMonthlyBudget(double amount) async {
    if (amount < 0) return;
    _monthlyBudget = amount;
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.saveMonthlyBudget(amount);
  }

  Future<void> updateStartingBalance(double amount) async {
    _startingBalance = amount;
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.saveStartingBalance(amount);
  }

  // ============================================================
  // GOALS & INVESTMENTS MUTATIONS
  // ============================================================

  Future<void> updateGoals(List<FinancialGoal> newGoals) async {
    _goals.clear();
    _goals.addAll(newGoals);
    notifyListeners();
  }

  Future<void> addInvestment(InvestmentModel inv) async {
    _investments.add(inv);
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.saveInvestments(_investments);
  }

  Future<void> updateInvestment(InvestmentModel inv) async {
    final idx = _investments.indexWhere((i) => i.id == inv.id);
    if (idx != -1) {
      _investments[idx] = inv;
      notifyListeners();
      final storage = await StorageService.getInstance();
      await storage.saveInvestments(_investments);
    }
  }

  Future<void> deleteInvestment(String id) async {
    _investments.removeWhere((i) => i.id == id);
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.saveInvestments(_investments);
  }

  Future<void> addDebt(DebtModel debt) async {
    _debts.add(debt);
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.saveDebts(_debts);
  }

  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.saveDebts(_debts);
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Future<String> exportToCsv() async {
    final storage = await StorageService.getInstance();
    return storage.exportTransactionsToCsv(_transactions);
  }

  Future<void> saveInvestmentPlan(AiInvestmentPlan plan) async {
    _savedInvestmentPlan = plan;
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.saveInvestmentPlan(plan);
  }

  Future<void> clearAllData() async {
    _transactions.clear();
    _goals.clear();
    _investments.clear();
    _debts.clear();
    _savedInvestmentPlan = null;
    _monthlyBudget = 25000;
    _startingBalance = 0;
    notifyListeners();
    final storage = await StorageService.getInstance();
    await storage.clearAllData();
  }
}