import '../models/bank_statement_models.dart';
import 'category_service.dart';
import 'ocr_service.dart';
import 'statement_parser_service.dart';

class StatementOcrService {
  /// Runs OCR on an image file of a bank statement and extracts transactions.
  static Future<List<BankTransaction>> parseStatementFromImage(String imagePath) async {
    final rawText = await OcrService.extractTextFromImage(imagePath);
    if (rawText.trim().isEmpty) {
      throw Exception('OCR could not detect any readable text on this statement image.');
    }

    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final List<BankTransaction> transactions = [];

    // Line matching regex for Date
    final datePattern = RegExp(r'\b([0-3]?[0-9][/\-\.][0-1]?[0-9][/\-\.](?:20\d{2}|\d{2}))\b');

    for (final line in lines) {
      final dateMatch = datePattern.firstMatch(line);
      if (dateMatch == null) continue;

      final parsedDate = StatementParserService.parseDate(dateMatch.group(1));
      if (parsedDate == null) continue;

      // Find amounts in line
      final numberMatches = RegExp(r'(?:[₹$€]|rs\.?)?\s*([0-9]+(?:,[0-9]{2,3})*(?:\.[0-9]{2})?)', caseSensitive: false)
          .allMatches(line)
          .toList();

      if (numberMatches.isEmpty) continue;

      double amount = 0.0;
      double? balance;
      bool isIncome = false;

      String description = line.replaceFirst(dateMatch.group(0)!, '').trim();

      if (numberMatches.length >= 2) {
        amount = StatementParserService.tryParseAmount(numberMatches[0].group(1)) ?? 0.0;
        balance = StatementParserService.tryParseAmount(numberMatches.last.group(1));
      } else {
        amount = StatementParserService.tryParseAmount(numberMatches[0].group(1)) ?? 0.0;
      }

      if (amount <= 0) continue;

      final lower = line.toLowerCase();
      if (lower.contains('cr') || lower.contains('credit') || lower.contains('deposit') || lower.contains('salary')) {
        isIncome = true;
      } else {
        isIncome = false;
      }

      for (final m in numberMatches) {
        description = description.replaceFirst(m.group(0)!, '');
      }
      description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (description.isEmpty) description = 'Statement Entry';

      final cat = CategoryService.categorize(description);

      transactions.add(BankTransaction(
        date: parsedDate,
        description: description,
        amount: amount,
        isIncome: isIncome,
        balance: balance,
        category: isIncome ? 'Salary' : cat.category,
        confidence: 0.75,
        rawLine: line,
      ));
    }

    if (transactions.isEmpty) {
      throw Exception('Could not extract valid transaction rows from the scanned statement. Please verify the image quality.');
    }

    return transactions;
  }
}
