import 'package:flutter_test/flutter_test.dart';
import 'package:finpilot_ai/services/receipt_scanner_service.dart';

void main() {
  group('ReceiptScannerService — OCR regex extraction', () {
    test('extracts total from receipt text', () {
      final text = '''
ABC Restaurant
Date: 15 Jan 2024
------
Burger    ₹200
Fries     ₹150
------
Total:    ₹450.00
GST 5%    ₹22.50
Grand Total: ₹472.50
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.amount, closeTo(472.50, 1.0));
      expect(result.currency, equals('INR'));
    });

    test('extracts two-line total where amount is on subsequent line', () {
      final text = '''
Zomato Delivery
TAX INVOICE
GSTIN: 27AAAAA0000A1Z5
Order #492810
TOTAL AMOUNT PAYABLE
₹850.00
Payment Method: UPI
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.amount, closeTo(850.00, 1.0));
      expect(result.merchant.toLowerCase(), contains('zomato'));
      expect(result.paymentMethod, equals('UPI'));
    });

    test('ignores noise like FSSAI or GSTIN when extracting merchant', () {
      final text = '''
TAX INVOICE
FSSAI Lic: 12345678901234
GSTIN: 07AAAAA0000A1Z5
*** BARBEQUE NATION ***
Date: 15-03-2024
Total: ₹2400.00
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.merchant.toLowerCase(), contains('barbeque nation'));
      expect(result.amount, closeTo(2400.00, 1.0));
    });

    test('extracts merchant name from first non-empty line', () {
      final text = '''
Swiggy Instamart
Date: 20 Jan 2024
Milk      ₹60
Total     ₹60
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.merchant.toLowerCase(), contains('swiggy'));
    });

    test('extracts date from receipt text', () {
      final text = '''
BigBazaar
Date: 12/03/2024
Bread     ₹45
Total     ₹45
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.date.day, equals(12));
      expect(result.date.month, equals(3));
      expect(result.date.year, equals(2024));
    });

    test('handles textual date format like 15 Jan 2024', () {
      final text = '''
Starbucks Coffee
Date: 15 Jan 2024
Cappuccino  ₹350
Total:      ₹350
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.date.day, equals(15));
      expect(result.date.month, equals(1));
      expect(result.date.year, equals(2024));
    });

    test('handles USD amounts', () {
      final text = '''
Amazon
Order Date: Jan 10, 2024
Product       \$29.99
Shipping      \$5.00
Total:        \$34.99
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.amount, closeTo(34.99, 1.0));
      expect(result.currency, equals('USD'));
    });

    test('handles empty OCR text gracefully', () {
      final result = ReceiptScannerService.parseReceipt('');
      expect(result.amount, equals(0.0));
      expect(result.merchant, equals('Store / Merchant'));
    });

    test('extracts amount without currency symbol from "Total 350"', () {
      final text = '''
Cafe Coffee Day
15 Jan 2024
Coffee   150
Cake     200
Total    350
''';
      final result = ReceiptScannerService.parseReceipt(text);
      expect(result.amount, closeTo(350, 5.0));
    });
  });
}
