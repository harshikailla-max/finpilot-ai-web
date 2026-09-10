import 'package:intl/intl.dart';

enum TransactionType {
  income,
  expense,
}

class FinanceTransaction {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String? merchant;
  final String source; // 'manual', 'receipt', 'bank_statement', 'imported'
  final String? receiptId;
  final String? bankReference;
  final bool isImported;
  final bool isRecurring;
  final DateTime createdAt;

  FinanceTransaction({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.paymentMethod = 'UPI',
    this.merchant,
    this.source = 'manual',
    this.receiptId,
    this.bankReference,
    this.isImported = false,
    this.isRecurring = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ============================================================
  // BACKWARD COMPATIBILITY HELPERS
  // ============================================================

  bool get isIncome => type.toLowerCase() == 'income';
  bool get isExpense => !isIncome;

  String? get note => description;

  String get transactionType => isIncome ? 'Income' : 'Expense';

  String get signedAmount {
    final formatter = NumberFormat('#,##,###.##');
    final formatted = formatter.format(amount);
    return '${isIncome ? '+' : '-'}₹$formatted';
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  FinanceTransaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? merchant,
    String? source,
    String? receiptId,
    String? bankReference,
    bool? isImported,
    bool? isRecurring,
    DateTime? createdAt,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchant: merchant ?? this.merchant,
      source: source ?? this.source,
      receiptId: receiptId ?? this.receiptId,
      bankReference: bankReference ?? this.bankReference,
      isImported: isImported ?? this.isImported,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================
  // JSON SERIALIZATION
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'merchant': merchant,
      'source': source,
      'receiptId': receiptId,
      'bankReference': bankReference,
      'isImported': isImported,
      'isRecurring': isRecurring,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? 'Untitled Transaction',
      description: map['description']?.toString() ?? map['note']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type']?.toString() ?? ((map['isIncome'] == true) ? 'income' : 'expense'),
      category: map['category']?.toString() ?? 'Other',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: map['paymentMethod']?.toString() ?? 'UPI',
      merchant: map['merchant']?.toString(),
      source: map['source']?.toString() ?? 'manual',
      receiptId: map['receiptId']?.toString(),
      bankReference: map['bankReference']?.toString(),
      isImported: map['isImported'] as bool? ?? false,
      isRecurring: map['isRecurring'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) =>
      FinanceTransaction.fromMap(json);

  @override
  String toString() {
    return 'FinanceTransaction(id: $id, title: $title, amount: $amount, type: $type, category: $category, date: $date, source: $source)';
  }
}

// Backward compatibility alias so existing code referring to TransactionModel works seamlessly
typedef TransactionModel = FinanceTransaction;