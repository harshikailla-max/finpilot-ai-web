import 'dart:math' as math;
import '../models/bank_statement_models.dart';
import 'category_service.dart';

class ReceiptScannerService {
  /// Parses raw OCR text extracted from a receipt and returns structured ParsedReceipt
  static ParsedReceipt parseReceipt(String rawText, {String? imagePath}) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String currency = _detectCurrency(rawText);
    double? total = _extractTotal(lines, rawText);
    double? tax = _extractTax(lines);
    DateTime? date = _extractDate(rawText);
    String? invoiceNo = _extractInvoiceNumber(lines);
    String merchant = _extractMerchant(lines);
    String paymentMethod = _extractPaymentMethod(rawText);

    // Auto-categorize based on merchant or raw text
    final catResult = CategoryService.categorize(
      merchant.isNotEmpty && merchant != 'Store / Merchant'
          ? merchant
          : rawText,
    );

    double confidence = 0.4;
    if (total != null && total > 0) confidence += 0.3;
    if (merchant.isNotEmpty && merchant != 'Store / Merchant') confidence += 0.2;
    if (date != null) confidence += 0.1;

    return ParsedReceipt(
      merchant: merchant,
      amount: total ?? 0.0,
      date: date ?? DateTime.now(),
      category: catResult.category,
      paymentMethod: paymentMethod,
      tax: tax,
      currency: currency,
      invoiceNumber: invoiceNo,
      rawText: rawText,
      confidence: math.min(1.0, confidence),
      imagePath: imagePath,
    );
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  static String _detectCurrency(String text) {
    if (text.contains('₹') ||
        RegExp(r'\b(?:rs\.?|inr)\b', caseSensitive: false).hasMatch(text)) {
      return 'INR';
    }
    if (text.contains('\$') ||
        RegExp(r'\busd\b', caseSensitive: false).hasMatch(text)) {
      return 'USD';
    }
    if (text.contains('€') ||
        RegExp(r'\beur\b', caseSensitive: false).hasMatch(text)) {
      return 'EUR';
    }
    return 'INR';
  }

  // ============================================================
  // TOTAL AMOUNT
  // ============================================================

  static double? _extractTotal(List<String> lines, String fullText) {
    // 1. Check explicit Grand Total / Amount Payable keywords first
    final primaryKeywords = [
      'grand total',
      'amount payable',
      'net payable',
      'total amount',
      'bill total',
      'total payable',
      'total due',
      'amount due',
      'balance due',
      'net amount',
      'total',
    ];

    for (final kw in primaryKeywords) {
      // Regex for keyword on same line or with amount
      final pattern = RegExp(
        '\\b${RegExp.escape(kw)}\\b'
        r'\s*[:=\-]?\s*(?:[₹$€]|rs\.?|inr|usd|eur)?\s*([0-9]+(?:[, ][0-9]{2,3})*(?:\.[0-9]{1,2})?)',
        caseSensitive: false,
      );

      final matches = pattern.allMatches(fullText);
      for (final m in matches) {
        final rawNum = m.group(1)?.replaceAll(RegExp(r'[, ]'), '');
        if (rawNum != null) {
          final val = double.tryParse(rawNum);
          if (val != null && _isValidAmount(val)) {
            return val;
          }
        }
      }
    }

    // 2. Multi-line total: Keyword on line i, amount on line i+1
    for (int i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      final hasTotalKw = primaryKeywords.any((kw) => lineLower.contains(kw));

      if (hasTotalKw) {
        // First check line itself for number
        final lineNum = _extractNumberFromLine(lines[i]);
        if (lineNum != null && _isValidAmount(lineNum)) {
          return lineNum;
        }

        // Check next line if available
        if (i + 1 < lines.length) {
          final nextNum = _extractNumberFromLine(lines[i + 1]);
          if (nextNum != null && _isValidAmount(nextNum)) {
            return nextNum;
          }
        }
      }
    }

    // 3. Fallback: Search for currency symbol accompanied amounts
    final currencyPattern = RegExp(
      r'(?:[₹$€]|rs\.?\s*|inr\s*)\s*([0-9]+(?:[, ][0-9]{2,3})*(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    final curMatches = currencyPattern.allMatches(fullText);
    double maxCurFound = 0.0;
    for (final m in curMatches) {
      final rawNum = m.group(1)?.replaceAll(RegExp(r'[, ]'), '');
      if (rawNum != null) {
        final val = double.tryParse(rawNum);
        if (val != null && _isValidAmount(val) && val > maxCurFound) {
          maxCurFound = val;
        }
      }
    }
    if (maxCurFound > 0) return maxCurFound;

    // 4. Fallback: bottom-up scan for line with numbers near end of receipt
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].toLowerCase();
      if (line.contains('paid') || line.contains('card') || line.contains('cash') || line.contains('upi')) {
        final num = _extractNumberFromLine(lines[i]);
        if (num != null && _isValidAmount(num)) return num;
      }
    }

    return null;
  }

  static double? _extractNumberFromLine(String line) {
    // Exclude phone numbers, pin codes, GSTIN
    if (RegExp(r'\b[6-9]\d{9}\b').hasMatch(line) ||
        RegExp(r'\b\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}\b').hasMatch(line)) {
      return null;
    }

    final matches = RegExp(r'([0-9]+(?:[, ][0-9]{2,3})*(?:\.[0-9]{1,2})?)')
        .allMatches(line);

    for (final m in matches.toList().reversed) {
      final raw = m.group(1)?.replaceAll(RegExp(r'[, ]'), '');
      if (raw != null) {
        final val = double.tryParse(raw);
        if (val != null && _isValidAmount(val)) return val;
      }
    }
    return null;
  }

  static bool _isValidAmount(double val) {
    // Filter out 0, negative, or unrealistic numbers (e.g. barcodes, phone numbers, years)
    if (val <= 0) return false;
    if (val >= 10000000) return false; // 1 Crore+ usually barcode or invoice ref
    if (val >= 1900 && val <= 2100 && val == val.roundToDouble()) {
      return false; // likely year
    }
    return true;
  }

  // ============================================================
  // TAX
  // ============================================================

  static double? _extractTax(List<String> lines) {
    final taxPattern = RegExp(
      r'(?:gst|cgst|sgst|igst|vat|tax|sales\s+tax)\s*[:=\-]?\s*(?:[₹$€]|rs\.?|inr)?\s*([0-9]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );

    double totalTax = 0.0;
    for (final line in lines) {
      // Don't mistake GSTIN number for tax amount
      if (line.toLowerCase().contains('gstin') || line.toLowerCase().contains('tax invoice')) {
        continue;
      }
      final match = taxPattern.firstMatch(line);
      if (match != null) {
        final val = double.tryParse(match.group(1) ?? '');
        if (val != null && val > 0 && val < 500000) {
          totalTax += val;
        }
      }
    }
    return totalTax > 0 ? totalTax : null;
  }

  // ============================================================
  // DATE
  // ============================================================

  static DateTime? _extractDate(String text) {
    // 1. Textual month format: 15 Jan 2024 or 15-Jan-2024 or Jan 15, 2024
    final monthMap = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };

    final textMonthPattern = RegExp(
      r'\b([0-3]?[0-9])[\s\-\/\.](jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*[\s\-\/\.]*(20\d{2}|\d{2})\b',
      caseSensitive: false,
    );
    final mText = textMonthPattern.firstMatch(text);
    if (mText != null) {
      final d = int.tryParse(mText.group(1)!) ?? 1;
      final mStr = mText.group(2)!.toLowerCase().substring(0, 3);
      final m = monthMap[mStr] ?? 1;
      var y = int.tryParse(mText.group(3)!) ?? DateTime.now().year;
      if (y < 100) y += 2000;
      return DateTime(y, m, d);
    }

    // 2. dd/MM/yyyy or dd-MM-yyyy
    final dmyPattern = RegExp(r'\b([0-3]?[0-9])[/\-\.]([0-1]?[0-9])[/\-\.](20\d{2}|\d{2})\b');
    final match1 = dmyPattern.firstMatch(text);
    if (match1 != null) {
      final d = int.tryParse(match1.group(1)!) ?? 1;
      final m = int.tryParse(match1.group(2)!) ?? 1;
      var y = int.tryParse(match1.group(3)!) ?? DateTime.now().year;
      if (y < 100) y += 2000;
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        try {
          return DateTime(y, m, d);
        } catch (_) {}
      }
    }

    // 3. yyyy-MM-dd
    final ymdPattern = RegExp(r'\b(20\d{2})[/\-\.]([0-1]?[0-9])[/\-\.]([0-3]?[0-9])\b');
    final match2 = ymdPattern.firstMatch(text);
    if (match2 != null) {
      final y = int.tryParse(match2.group(1)!) ?? DateTime.now().year;
      final m = int.tryParse(match2.group(2)!) ?? 1;
      final d = int.tryParse(match2.group(3)!) ?? 1;
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        try {
          return DateTime(y, m, d);
        } catch (_) {}
      }
    }

    return null;
  }

  // ============================================================
  // INVOICE NUMBER
  // ============================================================

  static String? _extractInvoiceNumber(List<String> lines) {
    final invPattern = RegExp(
      r'(?:invoice|inv|bill|receipt|tax\s+inv|token)\s*(?:no|num|number|#)?\s*[:#-]?\s*([A-Za-z0-9\-_/]{3,})',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = invPattern.firstMatch(line);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  // ============================================================
  // MERCHANT
  // ============================================================

  static String _extractMerchant(List<String> lines) {
    final ignoredPrefixes = [
      'tax invoice',
      'cash memo',
      'bill of supply',
      'retail invoice',
      'invoice',
      'receipt',
      'welcome',
      'original for recipient',
      'duplicate for supplier',
      'gstin',
      'gst',
      'phone',
      'tel',
      'mob',
      'contact',
      'date',
      'time',
      'fssai',
      'cin',
      'pan',
      'tin',
      'st no',
      'table',
      'token',
      'order',
      'cashier',
      'terminal',
      'address',
      'road',
      'street',
      'pin',
      'pincode',
      'thank you',
      'visit again',
      'http',
      'www.',
    ];

    for (final line in lines) {
      final lower = line.toLowerCase().trim();
      bool shouldIgnore = false;

      for (final prefix in ignoredPrefixes) {
        if (lower.startsWith(prefix) || lower == prefix) {
          shouldIgnore = true;
          break;
        }
      }

      // Check if line is purely address or phone
      if (RegExp(r'\b[6-9]\d{9}\b').hasMatch(line) ||
          RegExp(r'\b\d{6}\b').hasMatch(line) || // pincode
          RegExp(r'^\d+$').hasMatch(line)) {
        shouldIgnore = true;
      }

      if (!shouldIgnore && line.length >= 3) {
        // Clean leading and trailing special characters (e.g. *** CAFE COFFEE DAY ***)
        final cleaned = line.replaceAll(RegExp(r'^[^\w\s]+|[^\w\s]+$'), '').trim();
        if (cleaned.length >= 3 && !RegExp(r'^\d+$').hasMatch(cleaned)) {
          return cleaned;
        }
      }
    }

    return 'Store / Merchant';
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  static String _extractPaymentMethod(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('upi') ||
        lower.contains('gpay') ||
        lower.contains('google pay') ||
        lower.contains('phonepe') ||
        lower.contains('paytm') ||
        lower.contains('bhim')) {
      return 'UPI';
    }
    if (lower.contains('credit card')) return 'Credit Card';
    if (lower.contains('debit card')) return 'Debit Card';
    if (lower.contains('card') ||
        lower.contains('visa') ||
        lower.contains('mastercard') ||
        lower.contains('rupay') ||
        lower.contains('amex')) {
      return 'Card';
    }
    if (lower.contains('cash')) return 'Cash';
    if (lower.contains('net banking') || lower.contains('neft') || lower.contains('rtgs')) {
      return 'Bank';
    }
    return 'UPI';
  }
}
