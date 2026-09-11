import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/bank_statement_models.dart';
import '../services/statement_parser_service.dart';
import '../services/statement_analysis_service.dart';
import 'column_mapping_screen.dart';
import 'bank_statement_review_screen.dart';

class BankStatementImportScreen extends StatefulWidget {
  const BankStatementImportScreen({super.key});

  @override
  State<BankStatementImportScreen> createState() => _BankStatementImportScreenState();
}

class _BankStatementImportScreenState extends State<BankStatementImportScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);

  bool _isProcessing = false;
  String _statusText = '';
  StatementAnalysisResult? _lastAnalysis;


  // ============================================================
  // IMPORT CSV
  // ============================================================

  Future<void> _importCsv() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
              );

      if (result.isEmpty) {
        // User cancelled picker
        return;
      }

      final file = result.first;
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        _showSnackbar('The selected CSV file could not be read or is empty.');
        return;
      }

      setState(() {
        _isProcessing = true;
        _statusText = 'Reading CSV statement...';
      });

      // Attempt parsing
      StatementParseResult parseResult = await StatementParserService.parseCsv(bytes);

      // If column auto-detection was uncertain, launch manual mapping screen
      if (parseResult.requiresManualMapping) {
        setState(() {
          _isProcessing = false;
          _statusText = '';
        });

        if (!mounted) return;

        final customMapping = await Navigator.push<StatementColumnMapping>(
          context,
          MaterialPageRoute(
            builder: (_) => ColumnMappingScreen(
              headers: parseResult.headers,
              initialMapping: parseResult.mapping,
            ),
          ),
        );

        if (customMapping == null) {
          // User cancelled mapping
          return;
        }

        setState(() {
          _isProcessing = true;
          _statusText = 'Parsing CSV with custom mapping...';
        });

        parseResult = await StatementParserService.parseCsv(
          bytes,
          customMapping: customMapping,
        );
      }

      if (!mounted) return;

      if (parseResult.transactions.isEmpty) {
        _showSnackbar('No valid transaction rows found in the CSV file.');
        return;
      }

      // Navigate to Review Screen
      await _navigateToReview(parseResult.transactions, file.name);
    } catch (e) {
      _showSnackbar('CSV Import Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = '';
        });
      }
    }
  }

  // ============================================================
  // IMPORT EXCEL
  // ============================================================

  Future<void> _importExcel() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
              );

      if (result.isEmpty) {
        return;
      }

      final file = result.first;
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        _showSnackbar('The selected Excel file is empty.');
        return;
      }

      setState(() {
        _isProcessing = true;
        _statusText = 'Analyzing Excel statement...';
      });

      StatementParseResult parseResult = await StatementParserService.parseExcel(bytes);

      if (parseResult.requiresManualMapping) {
        setState(() {
          _isProcessing = false;
          _statusText = '';
        });

        if (!mounted) return;

        final customMapping = await Navigator.push<StatementColumnMapping>(
          context,
          MaterialPageRoute(
            builder: (_) => ColumnMappingScreen(
              headers: parseResult.headers,
              initialMapping: parseResult.mapping,
            ),
          ),
        );

        if (customMapping == null) return;

        setState(() {
          _isProcessing = true;
          _statusText = 'Parsing Excel with custom mapping...';
        });

        parseResult = await StatementParserService.parseExcel(
          bytes,
          customMapping: customMapping,
        );
      }

      if (!mounted) return;

      if (parseResult.transactions.isEmpty) {
        _showSnackbar('No valid transactions found in the Excel sheet.');
        return;
      }

      await _navigateToReview(parseResult.transactions, file.name);
    } catch (e) {
      _showSnackbar('Excel Import Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = '';
        });
      }
    }
  }

  // ============================================================
  // IMPORT PDF
  // ============================================================

  Future<void> _importPdf() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.isEmpty) {
        return;
      }

      final file = result.first;
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        _showSnackbar('The selected PDF is empty.');
        return;
      }

      setState(() {
        _isProcessing = true;
        _statusText = 'Extracting PDF intelligence & transactions...';
      });

      final analysis = await StatementAnalysisService.analyzeStatement(
        bytes: bytes,
        fileName: file.name,
      );

      setState(() {
        _lastAnalysis = analysis;
      });

      if (!mounted) return;

      if (analysis.transactions.isNotEmpty) {
        await _navigateToReview(analysis.transactions, file.name);
      } else {
        _showSnackbar('No transactions could be extracted from this PDF. You may also try CSV or Screenshot import.');
      }
    } catch (e) {
      _showSnackbar('PDF Import Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = '';
        });
      }
    }
  }

  // ============================================================
  // SCAN STATEMENT (SCREENSHOT / IMAGE INTELLIGENCE)
  // ============================================================

  Future<void> _scanStatement() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        _showSnackbar('Could not load image bytes.');
        return;
      }

      setState(() {
        _isProcessing = true;
        _statusText = 'Analyzing statement screenshot with FinPilot AI...';
      });

      final analysis = await StatementAnalysisService.analyzeStatement(
        bytes: bytes,
        fileName: image.name,
      );

      setState(() {
        _lastAnalysis = analysis;
      });

      if (!mounted) return;

      if (analysis.transactions.isNotEmpty) {
        await _navigateToReview(analysis.transactions, 'Statement Screenshot');
      } else {
        _showSnackbar('No recognizable transaction entries found in the image.');
      }
    } catch (e) {
      _showSnackbar('Statement Screenshot Analysis Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = '';
        });
      }
    }
  }

  // ============================================================
  // NAVIGATION HELPER
  // ============================================================

  Future<void> _navigateToReview(List<BankTransaction> transactions, String title) async {
    final imported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BankStatementReviewScreen(
          initialTransactions: transactions,
          sourceName: title,
        ),
      ),
    );

    if (imported == true && mounted) {
      Navigator.pop(context);
    }
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: red, content: Text(msg, style: const TextStyle(color: Colors.white))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Import Bank Statement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: purple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.account_balance_rounded, color: cyan, size: 24),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'BANK INTEGRATION',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Import your statement seamlessly',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select your bank statement in CSV, Excel or PDF format. FinPilot AI auto-maps columns, auto-categorizes transactions, and detects duplicates.',
                          style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'IMPORT OPTIONS',
                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                  ),

                  const SizedBox(height: 14),

                  // Button 1: CSV
                  _importOptionTile(
                    title: 'IMPORT CSV',
                    subtitle: 'Comma, semicolon, or pipe separated bank files',
                    icon: Icons.table_chart_rounded,
                    badge: 'RECOMMENDED',
                    color: cyan,
                    onTap: _isProcessing ? null : _importCsv,
                  ),

                  const SizedBox(height: 14),

                  // Button 2: Excel
                  _importOptionTile(
                    title: 'IMPORT EXCEL',
                    subtitle: 'Microsoft Excel (.xlsx, .xls) worksheets',
                    icon: Icons.grid_on_rounded,
                    badge: 'XLSX',
                    color: green,
                    onTap: _isProcessing ? null : _importExcel,
                  ),

                  const SizedBox(height: 14),

                  // Button 3: PDF
                  _importOptionTile(
                    title: 'IMPORT PDF STATEMENT',
                    subtitle: 'Native text or digital e-statements from any bank',
                    icon: Icons.picture_as_pdf_rounded,
                    badge: 'PDF',
                    color: red,
                    onTap: _isProcessing ? null : _importPdf,
                  ),

                  const SizedBox(height: 14),

                  // Button 4: STATEMENT SCREENSHOT / IMAGE
                  _importOptionTile(
                    title: 'STATEMENT SCREENSHOT / PHOTO',
                    subtitle: 'UPI app screenshot, passbook photo, or bank slip',
                    icon: Icons.document_scanner_rounded,
                    badge: 'INTELLIGENCE',
                    color: purple,
                    onTap: _isProcessing ? null : _scanStatement,
                  ),

                  if (_lastAnalysis != null) ...[
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cardColor,
                            purple.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: purple.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: cyan, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'LATEST STATEMENT INTELLIGENCE',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _lastAnalysis!.formatType,
                                  style: const TextStyle(color: cyan, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _lastAnalysis!.aiSummary,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Extracted: ${_lastAnalysis!.totalCount} txns',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                              TextButton(
                                onPressed: () => _navigateToReview(_lastAnalysis!.transactions, _lastAnalysis!.fileName),
                                child: const Text('Review Transactions →', style: TextStyle(color: cyan, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  // Supported Banks Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: green, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'All statement processing happens locally on your device. Your banking data is never sent to external servers.',
                            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: cyan),
                      const SizedBox(height: 20),
                      Text(
                        _statusText,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _importOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.3), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
