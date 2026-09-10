import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bank_statement_models.dart';
import '../providers/finance_provider.dart';
import '../services/category_service.dart';
import '../services/statement_parser_service.dart';

class BankStatementReviewScreen extends StatefulWidget {
  final List<BankTransaction> initialTransactions;
  final String sourceName;

  const BankStatementReviewScreen({
    super.key,
    required this.initialTransactions,
    this.sourceName = 'Bank Statement',
  });

  @override
  State<BankStatementReviewScreen> createState() => _BankStatementReviewScreenState();
}

class _BankStatementReviewScreenState extends State<BankStatementReviewScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);
  static const Color orange = Color(0xFFFFB86B);

  late List<BankTransaction> _transactions;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.initialTransactions);
    // Run duplicate detection against existing transactions in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final existing = context.read<FinanceProvider>().transactions;
      final withDuplicates = StatementParserService.detectDuplicates(
        imported: _transactions,
        existing: existing,
      );
      setState(() {
        _transactions = withDuplicates;
        // By default, unselect detected duplicates
        for (final t in _transactions) {
          if (t.isDuplicate) {
            t.selected = false;
          }
        }
      });
    });
  }

  double get _totalIncome => _transactions
      .where((t) => t.selected && t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.selected && !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  int get _selectedCount => _transactions.where((t) => t.selected).length;

  void _selectAll() {
    setState(() {
      for (var t in _transactions) {
        t.selected = true;
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (var t in _transactions) {
        t.selected = false;
      }
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
  }

  Future<void> _editTransaction(int index) async {
    final tx = _transactions[index];
    final descController = TextEditingController(text: tx.description);
    final amountController = TextEditingController(text: tx.amount.toStringAsFixed(2));
    String category = tx.category;
    bool isIncome = tx.isIncome;
    DateTime date = tx.date;

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Edit Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Amount (₹)'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Type:', style: TextStyle(color: Colors.white70)),
                        const Spacer(),
                        ChoiceChip(
                          label: const Text('Expense'),
                          selected: !isIncome,
                          selectedColor: red.withValues(alpha: 0.3),
                          onSelected: (val) => setDialogState(() => isIncome = !val),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Income'),
                          selected: isIncome,
                          selectedColor: green.withValues(alpha: 0.3),
                          onSelected: (val) => setDialogState(() => isIncome = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: CategoryService.standardCategories.contains(category) ? category : 'Other',
                      dropdownColor: cardColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: CategoryService.standardCategories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(backgroundColor: purple),
                  child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true) {
      final newAmt = double.tryParse(amountController.text.trim()) ?? tx.amount;
      setState(() {
        _transactions[index] = tx.copyWith(
          description: descController.text.trim(),
          amount: newAmt,
          isIncome: isIncome,
          category: category,
          date: date,
        );
      });
    }
  }

  Future<void> _importSelected() async {
    final toImport = _transactions.where((t) => t.selected).toList();

    if (toImport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: orange,
          content: Text('Please select at least one transaction to import.'),
        ),
      );
      return;
    }

    setState(() => _isImporting = true);

    try {
      final financeTransactions = toImport
          .map((bt) => bt.toFinanceTransaction(source: 'bank_statement'))
          .toList();

      await context.read<FinanceProvider>().importTransactions(financeTransactions);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardColor,
          content: Text(
            'Successfully imported ${financeTransactions.length} transactions!',
            style: const TextStyle(color: green, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Return to dashboard
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: red, content: Text('Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          widget.sourceName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header summary card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BANK STATEMENT REVIEW',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_selectedCount of ${_transactions.length} selected',
                          style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryStat(
                          label: 'Selected Income',
                          value: '+₹${_totalIncome.toStringAsFixed(0)}',
                          color: green,
                        ),
                      ),
                      Container(width: 1, height: 35, color: Colors.white12),
                      Expanded(
                        child: _summaryStat(
                          label: 'Selected Expenses',
                          value: '-₹${_totalExpense.toStringAsFixed(0)}',
                          color: red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Select All / Deselect All Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _selectAll,
                  icon: const Icon(Icons.select_all_rounded, size: 16, color: cyan),
                  label: const Text('SELECT ALL', style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: _deselectAll,
                  icon: const Icon(Icons.deselect_rounded, size: 16, color: Colors.white54),
                  label: const Text('DESELECT ALL', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text('No transactions to display.', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return _buildTransactionCard(tx, index);
                    },
                  ),
          ),
        ],
      ),

      // Bottom Bar with IMPORT SELECTED
      bottomSheet: Container(
        color: cardColor,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isImporting ? null : _importSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: _isImporting
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text(
                    'IMPORT SELECTED ($_selectedCount)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _summaryStat({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BankTransaction tx, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tx.isDuplicate
              ? orange.withValues(alpha: 0.5)
              : tx.selected
                  ? purple.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Duplicate Warning Banner if detected
          if (tx.isDuplicate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Possible duplicate: ${tx.duplicateReason}',
                      style: const TextStyle(color: orange, fontSize: 11),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => tx.selected = !tx.selected);
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                    child: Text(
                      tx.selected ? 'Skip' : 'Include',
                      style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Checkbox(
              value: tx.selected,
              activeColor: purple,
              onChanged: (val) {
                setState(() => tx.selected = val ?? false);
              },
            ),
            title: Text(
              tx.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: Row(
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(tx.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tx.category,
                    style: const TextStyle(color: cyan, fontSize: 10),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${tx.isIncome ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: tx.isIncome ? green : red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 18),
                  color: cardColor,
                  onSelected: (action) {
                    if (action == 'edit') {
                      _editTransaction(index);
                    } else if (action == 'delete') {
                      _deleteTransaction(index);
                    } else if (action == 'toggle_type') {
                      setState(() => tx.isIncome = !tx.isIncome);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
                    PopupMenuItem(
                      value: 'toggle_type',
                      child: Text(tx.isIncome ? 'Mark as Expense' : 'Mark as Income', style: const TextStyle(color: Colors.white)),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: red))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
