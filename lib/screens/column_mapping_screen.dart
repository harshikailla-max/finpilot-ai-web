import 'package:flutter/material.dart';
import '../models/bank_statement_models.dart';

class ColumnMappingScreen extends StatefulWidget {
  final List<String> headers;
  final StatementColumnMapping initialMapping;

  const ColumnMappingScreen({
    super.key,
    required this.headers,
    required this.initialMapping,
  });

  @override
  State<ColumnMappingScreen> createState() => _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends State<ColumnMappingScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color red = Color(0xFFFF6B81);

  int? _dateCol;
  int? _descCol;
  int? _amountCol;
  int? _debitCol;
  int? _creditCol;
  int? _balanceCol;

  bool _useDebitCreditColumns = false;

  @override
  void initState() {
    super.initState();
    _dateCol = widget.initialMapping.dateColumn;
    _descCol = widget.initialMapping.descriptionColumn;
    _amountCol = widget.initialMapping.amountColumn;
    _debitCol = widget.initialMapping.debitColumn;
    _creditCol = widget.initialMapping.creditColumn;
    _balanceCol = widget.initialMapping.balanceColumn;

    if (_debitCol != null && _creditCol != null) {
      _useDebitCreditColumns = true;
    }
  }

  void _applyMapping() {
    if (_dateCol == null) {
      _showSnackbar('Please select the Date column.');
      return;
    }

    if (_descCol == null) {
      _showSnackbar('Please select the Description / Narration column.');
      return;
    }

    if (_useDebitCreditColumns) {
      if (_debitCol == null || _creditCol == null) {
        _showSnackbar('Please select both Debit and Credit columns.');
        return;
      }
    } else {
      if (_amountCol == null) {
        _showSnackbar('Please select the Amount column.');
        return;
      }
    }

    final finalMapping = StatementColumnMapping(
      headers: widget.headers,
      dateColumn: _dateCol,
      descriptionColumn: _descCol,
      amountColumn: _useDebitCreditColumns ? null : _amountCol,
      debitColumn: _useDebitCreditColumns ? _debitCol : null,
      creditColumn: _useDebitCreditColumns ? _creditCol : null,
      balanceColumn: _balanceCol,
      confidence: 1.0,
    );

    Navigator.pop(context, finalMapping);
  }

  void _showSnackbar(String msg) {
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
          'Map Statement Columns',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded, color: cyan, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'FinPilot detected these headers. Please verify or match columns so transactions import accurately.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mandatory Date Column
            _columnDropdown(
              label: 'DATE COLUMN (Required)',
              selectedValue: _dateCol,
              icon: Icons.calendar_today_rounded,
              isRequired: true,
              onChanged: (val) => setState(() => _dateCol = val),
            ),

            const SizedBox(height: 18),

            // Mandatory Description Column
            _columnDropdown(
              label: 'DESCRIPTION / NARRATION (Required)',
              selectedValue: _descCol,
              icon: Icons.description_outlined,
              isRequired: true,
              onChanged: (val) => setState(() => _descCol = val),
            ),

            const SizedBox(height: 20),

            // Toggle for Separate Debit/Credit vs Single Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Has separate Debit & Credit columns?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Switch(
                  value: _useDebitCreditColumns,
                  activeColor: cyan,
                  onChanged: (val) => setState(() => _useDebitCreditColumns = val),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (!_useDebitCreditColumns)
              _columnDropdown(
                label: 'AMOUNT COLUMN (Required)',
                selectedValue: _amountCol,
                icon: Icons.currency_rupee_rounded,
                isRequired: true,
                onChanged: (val) => setState(() => _amountCol = val),
              )
            else ...[
              _columnDropdown(
                label: 'DEBIT / WITHDRAWAL COLUMN',
                selectedValue: _debitCol,
                icon: Icons.arrow_downward_rounded,
                isRequired: true,
                onChanged: (val) => setState(() => _debitCol = val),
              ),
              const SizedBox(height: 18),
              _columnDropdown(
                label: 'CREDIT / DEPOSIT COLUMN',
                selectedValue: _creditCol,
                icon: Icons.arrow_upward_rounded,
                isRequired: true,
                onChanged: (val) => setState(() => _creditCol = val),
              ),
            ],

            const SizedBox(height: 18),

            // Optional Balance Column
            _columnDropdown(
              label: 'BALANCE COLUMN (Optional)',
              selectedValue: _balanceCol,
              icon: Icons.account_balance_wallet_outlined,
              isRequired: false,
              onChanged: (val) => setState(() => _balanceCol = val),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _applyMapping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'CONTINUE PARSING',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _columnDropdown({
    required String label,
    required int? selectedValue,
    required IconData icon,
    required bool isRequired,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isRequired ? cyan : Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRequired && selectedValue == null ? red.withValues(alpha: 0.5) : Colors.white10,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedValue != null && selectedValue < widget.headers.length ? selectedValue : null,
              dropdownColor: cardColor,
              isExpanded: true,
              hint: const Text('Select matching header', style: TextStyle(color: Colors.white30, fontSize: 13)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
              items: List.generate(widget.headers.length, (idx) {
                return DropdownMenuItem<int>(
                  value: idx,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: Colors.white54),
                      const SizedBox(width: 10),
                      Text(
                        'Column ${idx + 1}: ${widget.headers[idx]}',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
