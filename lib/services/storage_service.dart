import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';
import '../models/investment_model.dart';
import '../models/debt_model.dart';
import '../models/ai_investment_goal_plan.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  static const String _keyTransactions = 'finpilot_transactions_v2';
  static const String _keyGoals = 'finpilot_goals_v2';
  static const String _keyCategoryBudgets = 'finpilot_category_budgets';
  static const String _keyMonthlyBudget = 'finpilot_monthly_budget';
  static const String _keyStartingBalance = 'finpilot_starting_balance';
  static const String _keyInvestments = 'finpilot_investments';
  static const String _keyDebts = 'finpilot_debts';
  static const String _keySavedInvestmentPlan = 'finpilot_saved_investment_plan';

  static const String _keyUserProfile = 'finpilot_user_profile';
  static const String _keyAiPreferences = 'finpilot_ai_preferences';
  static const String _keySecurityPin = 'finpilot_security_pin';

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Future<List<FinanceTransaction>> loadTransactions() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTransactions);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => FinanceTransaction.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveTransactions(List<FinanceTransaction> transactions) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final encoded = jsonEncode(transactions.map((t) => t.toMap()).toList());
    return prefs.setString(_keyTransactions, encoded);
  }

  Future<void> deleteImportedTransactions() async {
    final transactions = await loadTransactions();
    transactions.removeWhere((t) => t.isImported || t.source == 'bank_statement');
    await saveTransactions(transactions);
  }

  // ============================================================
  // GOALS
  // ============================================================

  Future<List<FinancialGoal>> loadGoals() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyGoals);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => FinancialGoal.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveGoals(List<FinancialGoal> goals) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final encoded = jsonEncode(goals.map((g) => g.toMap()).toList());
    return prefs.setString(_keyGoals, encoded);
  }

  // ============================================================
  // BUDGETS
  // ============================================================

  Future<Map<String, double>> loadCategoryBudgets() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCategoryBudgets);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {
        'Food': 6000,
        'Transport': 3000,
        'Shopping': 4000,
        'Bills': 5000,
        'Entertainment': 2500,
        'Health': 2000,
        'Education': 1500,
        'Other': 1000,
      };
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (e) {
      return {};
    }
  }

  Future<bool> saveCategoryBudgets(Map<String, double> budgets) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final encoded = jsonEncode(budgets);
    return prefs.setString(_keyCategoryBudgets, encoded);
  }

  Future<double> loadMonthlyBudget() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyBudget) ?? 25000.0;
  }

  Future<bool> saveMonthlyBudget(double amount) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setDouble(_keyMonthlyBudget, amount);
  }

  Future<double> loadStartingBalance() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getDouble(_keyStartingBalance) ?? 0.0;
  }

  Future<bool> saveStartingBalance(double amount) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setDouble(_keyStartingBalance, amount);
  }

  // ============================================================
  // INVESTMENTS
  // ============================================================

  Future<List<InvestmentModel>> loadInvestments() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyInvestments);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((i) => InvestmentModel.fromMap(i as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveInvestments(List<InvestmentModel> investments) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final encoded = jsonEncode(investments.map((i) => i.toMap()).toList());
    return prefs.setString(_keyInvestments, encoded);
  }

  // ============================================================
  // DEBTS
  // ============================================================

  Future<List<DebtModel>> loadDebts() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyDebts);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((d) => DebtModel.fromMap(d as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveDebts(List<DebtModel> debts) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final encoded = jsonEncode(debts.map((d) => d.toMap()).toList());
    return prefs.setString(_keyDebts, encoded);
  }

  // ============================================================
  // AI INVESTMENT GOAL PLAN
  // ============================================================

  Future<AiInvestmentPlan?> loadSavedInvestmentPlan() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySavedInvestmentPlan);
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }
    try {
      return AiInvestmentPlan.fromJson(jsonStr);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveInvestmentPlan(AiInvestmentPlan plan) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(_keySavedInvestmentPlan, plan.toJson());
  }

  // ============================================================
  // DATA MANAGEMENT & EXPORT
  // ============================================================

  Future<void> clearAllData() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_keyTransactions);
    await prefs.remove(_keyGoals);
    await prefs.remove(_keyCategoryBudgets);
    await prefs.remove(_keyMonthlyBudget);
    await prefs.remove(_keyStartingBalance);
    await prefs.remove(_keyInvestments);
    await prefs.remove(_keyDebts);
    await prefs.remove(_keySavedInvestmentPlan);
  }

  String exportTransactionsToCsv(List<FinanceTransaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Title,Description,Amount,Type,Category,PaymentMethod,Merchant,Source');
    for (final t in transactions) {
      final safeTitle = '"${t.title.replaceAll('"', '""')}"';
      final safeDesc = '"${(t.description ?? '').replaceAll('"', '""')}"';
      final safeMerchant = '"${(t.merchant ?? '').replaceAll('"', '""')}"';
      final dateStr = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      buffer.writeln('${t.id},$dateStr,$safeTitle,$safeDesc,${t.amount},${t.type},${t.category},${t.paymentMethod},$safeMerchant,${t.source}');
    }
    return buffer.toString();
  }

  // ============================================================
  // USER PROFILE
  // ============================================================

  Future<Map<String, String>> loadUserProfile() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {
        'name': 'Alex Johnson',
        'email': 'alex.johnson@finpilot.ai',
        'phone': '+91 98765 43210',
        'occupation': 'Software Engineer',
        'currency': '₹',
      };
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, val) => MapEntry(key, val.toString()));
    } catch (e) {
      return {
        'name': 'Alex Johnson',
        'email': 'alex.johnson@finpilot.ai',
        'phone': '+91 98765 43210',
        'occupation': 'Software Engineer',
        'currency': '₹',
      };
    }
  }

  Future<bool> saveUserProfile(Map<String, String> profile) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(_keyUserProfile, jsonEncode(profile));
  }

  // ============================================================
  // AI PREFERENCES
  // ============================================================

  Future<Map<String, String>> loadAiPreferences() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyAiPreferences);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {
        'tone': 'Balanced',
        'riskTolerance': 'Moderate',
        'notifications': 'true',
        'monthlyReport': 'true',
      };
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, val) => MapEntry(key, val.toString()));
    } catch (e) {
      return {
        'tone': 'Balanced',
        'riskTolerance': 'Moderate',
        'notifications': 'true',
        'monthlyReport': 'true',
      };
    }
  }

  Future<bool> saveAiPreferences(Map<String, String> preferences) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(_keyAiPreferences, jsonEncode(preferences));
  }

  // ============================================================
  // SECURITY PIN
  // ============================================================

  Future<String?> loadSecurityPin() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_keySecurityPin);
  }

  Future<bool> saveSecurityPin(String pin) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(_keySecurityPin, pin);
  }
}
