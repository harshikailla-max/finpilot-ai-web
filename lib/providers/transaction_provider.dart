import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final List<FinancialTransaction> _transactions = [];

  // ============================================================
  // GETTERS
  // ============================================================

  List<FinancialTransaction> get transactions =>
      List.unmodifiable(_transactions);

  List<FinancialTransaction> get incomes =>
      _transactions
          .where(
            (transaction) =>
                transaction.type == 'income',
          )
          .toList();

  List<FinancialTransaction> get expenses =>
      _transactions
          .where(
            (transaction) =>
                transaction.type == 'expense',
          )
          .toList();

  double get totalIncome {
    return incomes.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  double get totalExpense {
    return expenses.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  double get balance => totalIncome - totalExpense;

  // ============================================================
  // MONTHLY DATA
  // ============================================================

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();

    return date.month == now.month &&
        date.year == now.year;
  }

  List<FinancialTransaction> get currentMonthTransactions {
    return _transactions
        .where(
          (transaction) => _isCurrentMonth(transaction.date),
        )
        .toList();
  }

  double get monthlyIncome {
    return currentMonthTransactions
        .where(
          (transaction) =>
              transaction.type == 'income',
        )
        .fold(
          0.0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  double get monthlyExpense {
    return currentMonthTransactions
        .where(
          (transaction) =>
              transaction.type == 'expense',
        )
        .fold(
          0.0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  double get monthlySavings => monthlyIncome - monthlyExpense;

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  void addTransaction(FinancialTransaction transaction) {
    _transactions.add(transaction);

    _transactions.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    notifyListeners();
  }

  // ============================================================
  // ADD INCOME
  // ============================================================

  void addIncome({
    required String title,
    required double amount,
    required String category,
    String paymentMethod = 'Bank',
    String? note,
    DateTime? date,
  }) {
    final transaction = FinancialTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: 'income',
      category: category,
      paymentMethod: paymentMethod,
      description: note,
      date: date ?? DateTime.now(),
    );

    addTransaction(transaction);
  }

  // ============================================================
  // ADD EXPENSE
  // ============================================================

  void addExpense({
    required String title,
    required double amount,
    required String category,
    String paymentMethod = 'UPI',
    String? note,
    DateTime? date,
  }) {
    final transaction = FinancialTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: 'expense',
      category: category,
      paymentMethod: paymentMethod,
      description: note,
      date: date ?? DateTime.now(),
    );

    addTransaction(transaction);
  }

  // ============================================================
  // UPDATE TRANSACTION
  // ============================================================

  void updateTransaction(FinancialTransaction updatedTransaction) {
    final index = _transactions.indexWhere(
      (transaction) =>
          transaction.id == updatedTransaction.id,
    );

    if (index == -1) return;

    _transactions[index] = updatedTransaction;

    _transactions.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    notifyListeners();
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  void deleteTransaction(String id) {
    _transactions.removeWhere(
      (transaction) => transaction.id == id,
    );

    notifyListeners();
  }

  // ============================================================
  // CATEGORY ANALYTICS
  // ============================================================

  double categoryExpense(String category) {
    return expenses
        .where(
          (transaction) =>
              transaction.category.toLowerCase() ==
              category.toLowerCase(),
        )
        .fold(
          0.0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};

    for (final transaction in expenses) {
      result.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return result;
  }

  Map<String, double> get incomeByCategory {
    final Map<String, double> result = {};

    for (final transaction in incomes) {
      result.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return result;
  }

  String? get highestExpenseCategory {
    final data = expensesByCategory;

    if (data.isEmpty) return null;

    return data.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    ).key;
  }

  double get highestExpenseAmount {
    final data = expensesByCategory;

    if (data.isEmpty) return 0.0;

    return data.values.reduce(
      (a, b) => a > b ? a : b,
    );
  }

  // ============================================================
  // RECENT TRANSACTIONS
  // ============================================================

  List<FinancialTransaction> get recentTransactions {
    final sorted = List<FinancialTransaction>.from(
      _transactions,
    );

    sorted.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return sorted.take(10).toList();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<FinancialTransaction> searchTransactions(
    String query,
  ) {
    if (query.trim().isEmpty) {
      return transactions;
    }

    final lowerQuery = query.toLowerCase();

    return _transactions.where(
      (transaction) {
        return transaction.title
                .toLowerCase()
                .contains(lowerQuery) ||
            transaction.category
                .toLowerCase()
                .contains(lowerQuery) ||
            transaction.paymentMethod
                .toLowerCase()
                .contains(lowerQuery);
      },
    ).toList();
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<FinancialTransaction> transactionsByType(
    TransactionType type,
  ) {
    return _transactions
        .where(
          (transaction) =>
              transaction.type == type.name,
        )
        .toList();
  }

  List<FinancialTransaction> transactionsByCategory(
    String category,
  ) {
    return _transactions
        .where(
          (transaction) =>
              transaction.category.toLowerCase() ==
              category.toLowerCase(),
        )
        .toList();
  }

  // ============================================================
  // DEMO DATA
  // ============================================================

  void loadDemoData() {
    if (_transactions.isNotEmpty) return;

    final now = DateTime.now();

    _transactions.addAll([
      FinancialTransaction(
        id: '1',
        title: 'Monthly Salary',
        amount: 65000,
        type: 'income',
        category: 'Salary',
        paymentMethod: 'Bank',
        description: null,
        date: now.subtract(const Duration(days: 2)),
      ),

      FinancialTransaction(
        id: '2',
        title: 'Freelance Project',
        amount: 12000,
        type: 'income',
        category: 'Freelance',
        paymentMethod: 'UPI',
        description: null,
        date: now.subtract(const Duration(days: 4)),
      ),

      FinancialTransaction(
        id: '3',
        title: 'Swiggy Order',
        amount: 450,
        type: 'expense',
        category: 'Food',
        paymentMethod: 'UPI',
        description: null,
        date: now.subtract(const Duration(days: 1)),
      ),

      FinancialTransaction(
        id: '4',
        title: 'Uber Ride',
        amount: 320,
        type: 'expense',
        category: 'Transport',
        paymentMethod: 'UPI',
        description: null,
        date: now.subtract(const Duration(days: 3)),
      ),

      FinancialTransaction(
        id: '5',
        title: 'Netflix',
        amount: 649,
        type: 'expense',
        category: 'Entertainment',
        paymentMethod: 'Credit Card',
        description: null,
        date: now.subtract(const Duration(days: 5)),
      ),

      FinancialTransaction(
        id: '6',
        title: 'Amazon Shopping',
        amount: 2400,
        type: 'expense',
        category: 'Shopping',
        paymentMethod: 'UPI',
        description: null,
        date: now.subtract(const Duration(days: 6)),
      ),

      FinancialTransaction(
        id: '7',
        title: 'Electricity Bill',
        amount: 1800,
        type: 'expense',
        category: 'Bills',
        paymentMethod: 'Bank',
        description: null,
        date: now.subtract(const Duration(days: 7)),
      ),
    ]);

    _transactions.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    notifyListeners();
  }

  // ============================================================
  // CLEAR ALL DATA
  // ============================================================

  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }
}
