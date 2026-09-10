import 'package:uuid/uuid.dart';
import 'finance_transaction.dart';

class BankTransaction {
  final String id;
  DateTime date;
  String description;
  double amount;
  bool isIncome;
  double? balance;
  String category;
  double confidence;
  bool needsReview;
  bool isDuplicate;
  String? duplicateReason;
  bool selected;
  String? rawLine;

  BankTransaction({
    String? id,
    required this.date,
    required this.description,
    required this.amount,
    required this.isIncome,
    this.balance,
    this.category = 'Other',
    this.confidence = 1.0,
    this.needsReview = false,
    this.isDuplicate = false,
    this.duplicateReason,
    this.selected = true,
    this.rawLine,
  }) : id = id ?? const Uuid().v4();

  FinanceTransaction toFinanceTransaction({String source = 'bank_statement'}) {
    return FinanceTransaction(
      id: id,
      title: description,
      description: 'Statement Import: $description',
      amount: amount,
      type: isIncome ? 'income' : 'expense',
      category: category,
      date: date,
      paymentMethod: 'Bank',
      merchant: description,
      source: source,
      isImported: true,
      createdAt: DateTime.now(),
    );
  }

  BankTransaction copyWith({
    String? id,
    DateTime? date,
    String? description,
    double? amount,
    bool? isIncome,
    double? balance,
    String? category,
    double? confidence,
    bool? needsReview,
    bool? isDuplicate,
    String? duplicateReason,
    bool? selected,
    String? rawLine,
  }) {
    return BankTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      balance: balance ?? this.balance,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      needsReview: needsReview ?? this.needsReview,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      duplicateReason: duplicateReason ?? this.duplicateReason,
      selected: selected ?? this.selected,
      rawLine: rawLine ?? this.rawLine,
    );
  }
}

class StatementColumnMapping {
  int? dateColumn;
  int? descriptionColumn;
  int? amountColumn;
  int? debitColumn;
  int? creditColumn;
  int? balanceColumn;
  int? typeColumn;
  final List<String> headers;
  double confidence;

  StatementColumnMapping({
    this.dateColumn,
    this.descriptionColumn,
    this.amountColumn,
    this.debitColumn,
    this.creditColumn,
    this.balanceColumn,
    this.typeColumn,
    required this.headers,
    this.confidence = 0.0,
  });

  bool get isConfident =>
      dateColumn != null &&
      descriptionColumn != null &&
      (amountColumn != null || (debitColumn != null && creditColumn != null));
}

class ParsedReceipt {
  String merchant;
  double amount;
  DateTime date;
  String category;
  String paymentMethod;
  double? tax;
  String currency;
  String? invoiceNumber;
  String rawText;
  double confidence;
  String? imagePath;

  ParsedReceipt({
    required this.merchant,
    required this.amount,
    required this.date,
    this.category = 'Shopping',
    this.paymentMethod = 'UPI',
    this.tax,
    this.currency = 'INR',
    this.invoiceNumber,
    required this.rawText,
    this.confidence = 0.85,
    this.imagePath,
  });

  FinanceTransaction toFinanceTransaction() {
    return FinanceTransaction(
      id: const Uuid().v4(),
      title: merchant.isNotEmpty ? merchant : 'Receipt Expense',
      description: 'Scanned receipt ${invoiceNumber != null ? "Inv #$invoiceNumber" : ""}'.trim(),
      amount: amount,
      type: 'expense',
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      merchant: merchant,
      source: 'receipt',
      createdAt: DateTime.now(),
    );
  }
}
