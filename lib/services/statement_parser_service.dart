import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/bank_statement_models.dart';
import '../models/finance_transaction.dart';
import 'category_service.dart';

class StatementColumnMapper {
  static const List<String> dateSynonyms = [
    'date',
    'transaction date',
    'txn date',
    'value date',
    'posting date',
    'trans date',
    'post date',
  ];

  static const List<String> descriptionSynonyms = [
    'description',
    'narration',
    'narrative',
    'remarks',
    'details',
    'transaction details',
    'particulars',
    'payee',
    'merchant',
    'reference',
  ];

  static const List<String> debitSynonyms = [
    'debit',
    'withdrawal',
    'withdrawals',
    'dr',
    'debit amount',
    'withdrawal amount',
    'spent',
    'expense',
  ];

  static const List<String> creditSynonyms = [
    'credit',
    'deposit',
    'deposits',
    'cr',
    'credit amount',
    'deposit amount',
    'received',
    'income',
  ];

  static const List<String> amountSynonyms = [
    'amount',
    'transaction amount',
    'txn amount',
    'total amount',
    'net amount',
  ];

  static const List<String> balanceSynonyms = [
    'balance',
    'closing balance',
    'available balance',
    'running balance',
    'net balance',
  ];

  static const List<String> typeSynonyms = [
    'type',
    'txn type',
    'transaction type',
    'cr/dr',
    'dr/cr',
    'd/c',
  ];

  /// Inspects raw header strings and returns auto-detected column mappings.
  static StatementColumnMapping detectColumns(List<dynamic> rawHeaders) {
    final headers = rawHeaders.map((h) => h.toString().trim()).toList();
    final mapping = StatementColumnMapping(headers: headers);

    for (int i = 0; i < headers.length; i++) {
      final normalized = headers[i].toLowerCase().replaceAll(RegExp(r'[^a-z0-9/]'), ' ').trim();

      // Check date
      if (mapping.dateColumn == null && _matchesAny(normalized, dateSynonyms)) {
        mapping.dateColumn = i;
        continue;
      }

      // Check description / particulars
      if (mapping.descriptionColumn == null && _matchesAny(normalized, descriptionSynonyms)) {
        mapping.descriptionColumn = i;
        continue;
      }

      // Check debit
      if (mapping.debitColumn == null && _matchesAny(normalized, debitSynonyms)) {
        mapping.debitColumn = i;
        continue;
      }

      // Check credit
      if (mapping.creditColumn == null && _matchesAny(normalized, creditSynonyms)) {
        mapping.creditColumn = i;
        continue;
      }

      // Check amount
      if (mapping.amountColumn == null && _matchesAny(normalized, amountSynonyms)) {
        mapping.amountColumn = i;
        continue;
      }

      // Check balance
      if (mapping.balanceColumn == null && _matchesAny(normalized, balanceSynonyms)) {
        mapping.balanceColumn = i;
        continue;
      }

      // Check type
      if (mapping.typeColumn == null && _matchesAny(normalized, typeSynonyms)) {
        mapping.typeColumn = i;
        continue;
      }
    }

    // Confidence calculation
    double conf = 0.0;
    if (mapping.dateColumn != null) conf += 0.35;
    if (mapping.descriptionColumn != null) conf += 0.35;
    if (mapping.debitColumn != null && mapping.creditColumn != null) {
      conf += 0.30;
    } else if (mapping.amountColumn != null) {
      conf += 0.30;
    }
    mapping.confidence = conf;

    return mapping;
  }

  static bool _matchesAny(String header, List<String> synonyms) {
    for (final syn in synonyms) {
      if (header == syn || header.contains(syn)) {
        return true;
      }
    }
    return false;
  }
}

class StatementParserService {
  // ============================================================
  // AMOUNT PARSING
  // ============================================================

  /// Cleans strings like "₹1,500.50", "Rs. 1,500", "INR 1,500", "(500.00)" and parses to double.
  /// Throws FormatException if string does not contain a valid number.
  static double parseAmount(dynamic val) {
    if (val == null) throw const FormatException('Amount is null');
    if (val is num) return val.toDouble().abs();

    String str = val.toString().trim();
    if (str.isEmpty) throw const FormatException('Amount string is empty');

    // Handle parentheses as negative or amounts: (1500) -> 1500
    bool isNegative = str.startsWith('-') || (str.startsWith('(') && str.endsWith(')'));
    str = str.replaceAll('(', '').replaceAll(')', '');

    // Remove currency symbols, commas, whitespace, and prefixes
    str = str.replaceAll(RegExp(r'[₹$€£, ]'), '');
    str = str.replaceAll(RegExp(r'\b(?:rs\.?|inr|usd|eur|dr|cr)\b', caseSensitive: false), '');
    str = str.trim();

    final parsed = double.tryParse(str);
    if (parsed == null) {
      throw FormatException('Cannot parse amount: "$val"');
    }
    return isNegative ? -parsed.abs() : parsed.abs();
  }

  static double? tryParseAmount(dynamic val) {
    try {
      return parseAmount(val);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DATE PARSING
  // ============================================================

  /// Robust date parsing for formats:
  /// dd/MM/yyyy, dd-MM-yyyy, dd.MM.yyyy, MM/dd/yyyy, yyyy-MM-dd, yyyy/MM/dd
  static DateTime? parseDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;

    final str = val.toString().trim();
    if (str.isEmpty) return null;

    // Direct ISO try
    final directIso = DateTime.tryParse(str);
    if (directIso != null) return directIso;

    // Pattern 1: dd/MM/yyyy, dd-MM-yyyy, dd.MM.yyyy
    final dmy = RegExp(r'^([0-3]?[0-9])[/\-\.]([0-1]?[0-9])[/\-\.](20\d{2}|\d{2})$');
    final match1 = dmy.firstMatch(str);
    if (match1 != null) {
      final d = int.parse(match1.group(1)!);
      final m = int.parse(match1.group(2)!);
      var y = int.parse(match1.group(3)!);
      if (y < 100) y += 2000;
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        try {
          return DateTime(y, m, d);
        } catch (_) {}
      }
    }

    // Pattern 2: yyyy-MM-dd, yyyy/MM/dd
    final ymd = RegExp(r'^(20\d{2})[/\-\.]([0-1]?[0-9])[/\-\.]([0-3]?[0-9])$');
    final match2 = ymd.firstMatch(str);
    if (match2 != null) {
      final y = int.parse(match2.group(1)!);
      final m = int.parse(match2.group(2)!);
      final d = int.parse(match2.group(3)!);
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        try {
          return DateTime(y, m, d);
        } catch (_) {}
      }
    }

    // Pattern 3: dd Mon yyyy (e.g. 02 Aug 2026, 15-Jan-2026)
    final monthMap = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    };
    final textual = RegExp(r'^([0-3]?[0-9])[/\-\s]+([A-Za-z]{3})[A-Za-z]*[/\-\s]+(20\d{2}|\d{2})$');
    final match3 = textual.firstMatch(str);
    if (match3 != null) {
      final d = int.parse(match3.group(1)!);
      final monthName = match3.group(2)!.toLowerCase();
      var y = int.parse(match3.group(3)!);
      if (y < 100) y += 2000;
      final m = monthMap[monthName];
      if (m != null && d >= 1 && d <= 31) {
        try {
          return DateTime(y, m, d);
        } catch (_) {}
      }
    }

    return null;
  }

  // ============================================================
  // CSV PARSER
  // ============================================================

  /// Parses CSV bytes into structured BankTransactions.
  /// If customMapping is null, runs StatementColumnMapper.
  static Future<StatementParseResult> parseCsv(
    Uint8List bytes, {
    StatementColumnMapping? customMapping,
  }) async {
    String csvString;
    try {
      csvString = utf8.decode(bytes);
    } catch (_) {
      csvString = latin1.decode(bytes);
    }

    if (csvString.trim().isEmpty) {
      throw Exception('The selected CSV file is empty.');
    }

    // Support comma, semicolon, tab, and pipe delimiters
    String delimiter = ',';
    final firstLine = csvString.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    if (firstLine.contains('|')) {
      delimiter = '|';
    } else if (firstLine.contains(';') && !firstLine.contains(',')) {
      delimiter = ';';
    } else if (firstLine.contains('\t')) {
      delimiter = '\t';
    }

    final rows = CsvDecoder(
      fieldDelimiter: delimiter,
    ).convert(csvString.replaceAll('\r\n', '\n'));

    if (rows.isEmpty) {
      throw Exception('No tabular rows could be parsed from the CSV file.');
    }

    // Find header row (usually first non-empty row)
    int headerIndex = 0;
    for (int i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (r.isNotEmpty && r.any((cell) => cell.toString().trim().isNotEmpty)) {
        headerIndex = i;
        break;
      }
    }

    final headers = rows[headerIndex].map((c) => c.toString().trim()).toList();
    final mapping = customMapping ?? StatementColumnMapper.detectColumns(headers);

    // If mapping is not confident and no custom mapping provided, notify caller to show mapping screen
    if (!mapping.isConfident && customMapping == null) {
      return StatementParseResult(
        transactions: [],
        mapping: mapping,
        headers: headers,
        requiresManualMapping: true,
      );
    }

    final List<BankTransaction> transactions = [];

    // Parse subsequent data rows
    for (int i = headerIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      final parsedTx = _parseRow(row, mapping);
      if (parsedTx != null) {
        transactions.add(parsedTx);
      }
    }

    return StatementParseResult(
      transactions: transactions,
      mapping: mapping,
      headers: headers,
      requiresManualMapping: false,
    );
  }

  // ============================================================
  // EXCEL PARSER
  // ============================================================

  static Future<StatementParseResult> parseExcel(
    Uint8List bytes, {
    StatementColumnMapping? customMapping,
  }) async {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      throw Exception('The selected Excel file contains no worksheets.');
    }

    // Find first non-empty sheet
    Sheet? targetSheet;
    for (final sheet in excel.tables.values) {
      if (sheet.maxRows > 0) {
        targetSheet = sheet;
        break;
      }
    }

    if (targetSheet == null) {
      throw Exception('No tabular data found in Excel workbook.');
    }

    // Convert sheet rows to List<List<dynamic>>
    final List<List<dynamic>> rows = [];
    for (final row in targetSheet.rows) {
      rows.add(row.map((cell) => cell?.value?.toString() ?? '').toList());
    }

    if (rows.isEmpty) {
      throw Exception('Excel sheet is empty.');
    }

    // Detect header row
    int headerIndex = 0;
    for (int i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (r.isNotEmpty && r.any((c) => c.toString().trim().isNotEmpty)) {
        headerIndex = i;
        break;
      }
    }

    final headers = rows[headerIndex].map((c) => c.toString().trim()).toList();
    final mapping = customMapping ?? StatementColumnMapper.detectColumns(headers);

    if (!mapping.isConfident && customMapping == null) {
      return StatementParseResult(
        transactions: [],
        mapping: mapping,
        headers: headers,
        requiresManualMapping: true,
      );
    }

    final List<BankTransaction> transactions = [];

    for (int i = headerIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      final parsedTx = _parseRow(row, mapping);
      if (parsedTx != null) {
        transactions.add(parsedTx);
      }
    }

    return StatementParseResult(
      transactions: transactions,
      mapping: mapping,
      headers: headers,
      requiresManualMapping: false,
    );
  }

  // ============================================================
  // PDF PARSER
  // ============================================================

  static Future<StatementParseResult> parsePdf(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final textExtractor = PdfTextExtractor(document);
    final String extractedText = textExtractor.extractText();
    document.dispose();

    if (extractedText.trim().isEmpty) {
      throw Exception('Could not extract text from this PDF. It may be a scanned image or protected statement.');
    }

    final lines = extractedText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final List<BankTransaction> transactions = [];

    // Heuristic line parsing for bank statements
    // Matches lines containing a date and at least one numeric amount
    final lineDatePattern = RegExp(r'\b([0-3]?[0-9][/\-\.][0-1]?[0-9][/\-\.](?:20\d{2}|\d{2}))\b');

    for (final line in lines) {
      final dateMatch = lineDatePattern.firstMatch(line);
      if (dateMatch == null) continue;

      final parsedDate = parseDate(dateMatch.group(1));
      if (parsedDate == null) continue;

      // Extract all numbers with decimal places from line
      final numberMatches = RegExp(r'(?:[₹$€]|rs\.?)?\s*([0-9]+(?:,[0-9]{2,3})*(?:\.[0-9]{2}))', caseSensitive: false)
          .allMatches(line)
          .toList();

      if (numberMatches.isEmpty) continue;

      double amount = 0.0;
      double? balance;
      bool isIncome = false;

      // Clean line without date
      String description = line.replaceFirst(dateMatch.group(0)!, '').trim();

      if (numberMatches.length >= 2) {
        amount = tryParseAmount(numberMatches[0].group(1)) ?? 0.0;
        balance = tryParseAmount(numberMatches.last.group(1));
      } else {
        amount = tryParseAmount(numberMatches[0].group(1)) ?? 0.0;
      }

      // Check if line indicates credit or debit
      final lower = line.toLowerCase();
      if (lower.contains('cr') || lower.contains('credit') || lower.contains('deposit') || lower.contains('salary')) {
        isIncome = true;
      } else if (lower.contains('dr') || lower.contains('debit') || lower.contains('withdrawal') || lower.contains('paid')) {
        isIncome = false;
      }

      // Clean numbers out of description
      for (final m in numberMatches) {
        description = description.replaceFirst(m.group(0)!, '');
      }
      description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (description.isEmpty) description = 'Bank Transaction';

      final catResult = CategoryService.categorize(description);

      transactions.add(BankTransaction(
        date: parsedDate,
        description: description,
        amount: amount,
        isIncome: isIncome,
        balance: balance,
        category: catResult.category,
        confidence: 0.82,
        rawLine: line,
      ));
    }

    if (transactions.isEmpty) {
      throw Exception('FinPilot could not confidently extract transactions from this statement. Please use CSV or Manual Mapping.');
    }

    return StatementParseResult(
      transactions: transactions,
      mapping: StatementColumnMapping(headers: ['Date', 'Description', 'Amount']),
      headers: ['Date', 'Description', 'Amount'],
      requiresManualMapping: false,
    );
  }

  // ============================================================
  // ROW PARSER HELPER
  // ============================================================

  static BankTransaction? _parseRow(List<dynamic> row, StatementColumnMapping mapping) {
    DateTime? date;
    String description = '';
    double amount = 0.0;
    bool isIncome = false;
    double? balance;
    bool needsReview = false;

    // 1. Date
    if (mapping.dateColumn != null && mapping.dateColumn! < row.length) {
      date = parseDate(row[mapping.dateColumn!]);
    }
    date ??= DateTime.now();

    // 2. Description
    if (mapping.descriptionColumn != null && mapping.descriptionColumn! < row.length) {
      description = row[mapping.descriptionColumn!].toString().trim();
    }
    if (description.isEmpty) {
      description = 'Bank Transaction';
    }

    // 3. Separate Debit and Credit columns
    if (mapping.debitColumn != null &&
        mapping.creditColumn != null &&
        mapping.debitColumn! < row.length &&
        mapping.creditColumn! < row.length) {
      final debitVal = tryParseAmount(row[mapping.debitColumn!]);
      final creditVal = tryParseAmount(row[mapping.creditColumn!]);

      if (creditVal != null && creditVal > 0) {
        amount = creditVal;
        isIncome = true;
      } else if (debitVal != null && debitVal > 0) {
        amount = debitVal;
        isIncome = false;
      } else {
        // Both empty or zero, might be informational row
        return null;
      }
    }
    // 4. Single Amount Column
    else if (mapping.amountColumn != null && mapping.amountColumn! < row.length) {
      final rawAmount = tryParseAmount(row[mapping.amountColumn!]);
      if (rawAmount == null || rawAmount == 0) return null;

      amount = rawAmount.abs();

      // Check Type column
      if (mapping.typeColumn != null && mapping.typeColumn! < row.length) {
        final typeStr = row[mapping.typeColumn!].toString().trim().toLowerCase();
        if (typeStr.contains('cr') || typeStr.contains('credit') || typeStr.contains('deposit')) {
          isIncome = true;
        } else if (typeStr.contains('dr') || typeStr.contains('debit') || typeStr.contains('withdraw')) {
          isIncome = false;
        } else {
          isIncome = rawAmount > 0;
        }
      } else {
        // If row description has keywords
        final lower = description.toLowerCase();
        if (lower.contains('salary') || lower.contains('credited') || lower.contains('deposit')) {
          isIncome = true;
        } else {
          isIncome = false;
          needsReview = true;
        }
      }
    } else {
      return null;
    }

    // 5. Balance
    if (mapping.balanceColumn != null && mapping.balanceColumn! < row.length) {
      balance = tryParseAmount(row[mapping.balanceColumn!]);
    }

    final catResult = CategoryService.categorize(description);

    return BankTransaction(
      date: date,
      description: description,
      amount: amount,
      isIncome: isIncome,
      balance: balance,
      category: isIncome ? 'Salary' : catResult.category,
      confidence: mapping.confidence,
      needsReview: needsReview,
      rawLine: row.join(' | '),
    );
  }

  // ============================================================
  // DUPLICATE DETECTION (SECTION 19)
  // ============================================================

  /// Detects potential duplicates by comparing imported transactions against existing ones
  /// using Date, Amount, and Description similarity.
  static List<BankTransaction> detectDuplicates({
    required List<BankTransaction> imported,
    required List<FinanceTransaction> existing,
  }) {
    final updated = List<BankTransaction>.from(imported);

    for (final imp in updated) {
      for (final ext in existing) {
        // Amount match (within 1 rupee difference for rounding)
        final amountMatches = (imp.amount - ext.amount).abs() < 1.0;

        // Date match (within 2 days for bank clearance difference)
        final daysDiff = imp.date.difference(ext.date).inDays.abs();
        final dateMatches = daysDiff <= 2;

        // Description similarity (one contains the other or identical)
        final normImp = imp.description.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final normExt = ext.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final descMatches = normImp.isNotEmpty && normExt.isNotEmpty &&
            (normImp.contains(normExt) || normExt.contains(normImp));

        if (amountMatches && dateMatches && descMatches) {
          imp.isDuplicate = true;
          imp.duplicateReason =
              'Existing: ₹${ext.amount.toStringAsFixed(0)} • ${ext.title} (${ext.date.day}/${ext.date.month})';
          break;
        }
      }
    }

    return updated;
  }
}

class StatementParseResult {
  final List<BankTransaction> transactions;
  final StatementColumnMapping mapping;
  final List<String> headers;
  final bool requiresManualMapping;

  StatementParseResult({
    required this.transactions,
    required this.mapping,
    required this.headers,
    required this.requiresManualMapping,
  });
}
