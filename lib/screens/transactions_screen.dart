import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // ============================================================
  // THEME
  // ============================================================

  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);

  static const Color purple = Color(0xFF6C5CE7);
  static const Color lightPurple = Color(0xFF9A8CFF);

  static const Color cyan = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF2DD4A8);
  static const Color red = Color(0xFFFF6B81);

  // ============================================================
  // STATE
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedType = 'All';
  String _selectedCategory = 'All';
  String _sortBy = 'Newest';

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    final transactions =
        _getFilteredTransactions(finance.transactions);

    return Scaffold(
      backgroundColor: background,

      body: Stack(
        children: [
          _buildBackgroundGlow(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: RefreshIndicator(
                    color: purple,
                    backgroundColor: cardColor,
                    onRefresh: () async {
                      await Future.delayed(
                        const Duration(milliseconds: 600),
                      );
                    },
                    child: CustomScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
                              20,
                              10,
                              20,
                              0,
                            ),
                            child: Column(
                              children: [
                                _buildSummary(finance),

                                const SizedBox(height: 22),

                                _buildSearchBar(),

                                const SizedBox(height: 16),

                                _buildTypeFilters(),

                                const SizedBox(height: 14),

                                _buildCategoryAndSort(),

                                const SizedBox(height: 25),

                                _buildSectionHeader(
                                  transactions.length,
                                ),

                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),

                        transactions.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(),
                              )
                            : SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  30,
                                ),
                                sliver: SliverList(
                                  delegate:
                                      SliverChildBuilderDelegate(
                                    (context, index) {
                                      final transaction =
                                          transactions[index];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          bottom: 11,
                                        ),
                                        child:
                                            _buildTransactionCard(
                                          transaction,
                                          finance,
                                        ),
                                      );
                                    },
                                    childCount:
                                        transactions.length,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Widget _buildBackgroundGlow() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            left: -130,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSACTION CENTER',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Your Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  purple,
                  cyan,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(FinanceProvider finance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            purple.withValues(alpha: 0.22),
            cyan.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: purple.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: lightPurple,
                size: 20,
              ),

              const SizedBox(width: 9),

              const Text(
                'FINANCIAL OVERVIEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '${finance.transactions.length} records',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  icon:
                      Icons.arrow_downward_rounded,
                  label: 'Income',
                  value:
                      '₹${_formatCompact(finance.totalIncome)}',
                  color: green,
                ),
              ),

              Container(
                width: 1,
                height: 55,
                color: Colors.white.withValues(
                  alpha: 0.10,
                ),
              ),

              Expanded(
                child: _summaryItem(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Expenses',
                  value:
                      '₹${_formatCompact(finance.totalExpense)}',
                  color: red,
                ),
              ),

              Container(
                width: 1,
                height: 55,
                color: Colors.white.withValues(
                  alpha: 0.10,
                ),
              ),

              Expanded(
                child: _summaryItem(
                  icon:
                      Icons.account_balance_wallet_outlined,
                  label: 'Balance',
                  value:
                      '₹${_formatCompact(finance.balance)}',
                  color: cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 19,
        ),

        const SizedBox(height: 8),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,

          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.white38,
          ),

          hintText:
              'Search transactions, categories...',
          hintStyle: const TextStyle(
            color: Colors.white30,
            fontSize: 12,
          ),

          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white38,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
        ),
      ),
    );
  }

  // ============================================================
  // TYPE FILTERS
  // ============================================================

  Widget _buildTypeFilters() {
    return Row(
      children: [
        _typeFilter('All'),
        const SizedBox(width: 9),

        _typeFilter(
          'Income',
          color: green,
        ),

        const SizedBox(width: 9),

        _typeFilter(
          'Expense',
          color: red,
        ),
      ],
    );
  }

  Widget _typeFilter(
    String title, {
    Color? color,
  }) {
    final selected = _selectedType == title;

    final activeColor = color ?? purple;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = title;
          });
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withValues(alpha: 0.18)
                : cardColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? activeColor.withValues(alpha: 0.45)
                  : Colors.white.withValues(
                      alpha: 0.06,
                    ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? activeColor
                  : Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY + SORT
  // ============================================================

  Widget _buildCategoryAndSort() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedCategory,
            icon: Icons.category_outlined,
            items: const [
              'All',
              'Food',
              'Transport',
              'Shopping',
              'Bills',
              'Entertainment',
              'Health',
              'Education',
              'Salary',
              'Freelance',
              'Business',
              'Investment',
              'Bonus',
              'Other',
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildDropdown(
            value: _sortBy,
            icon: Icons.sort_rounded,
            items: const [
              'Newest',
              'Oldest',
              'Highest',
              'Lowest',
            ],
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding:
          const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF182338),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white38,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: cyan,
                    size: 15,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'TRANSACTIONS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 4),

              Text(
                'Your filtered financial activity',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count found',
            style: const TextStyle(
              color: lightPurple,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _buildTransactionCard(
    TransactionModel transaction,
    FinanceProvider finance,
  ) {
    final isIncome = transaction.isIncome;

    final color = isIncome ? green : red;

    return Dismissible(
      key: Key(transaction.id),

      direction: DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return await _confirmDelete(transaction);
      },

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: red.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: red,
        ),
      ),

      onDismissed: (_) {
        finance.deleteTransaction(transaction.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${transaction.title} deleted',
            ),
            backgroundColor: const Color(0xFF1B263B),
          ),
        );
      },

      child: GestureDetector(
        onTap: () {
          _showTransactionDetails(
            transaction,
            finance,
          );
        },

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  Colors.white.withValues(alpha: 0.06),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color:
                      color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Icon(
                  _categoryIcon(
                    transaction.category,
                  ),
                  color: color,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${transaction.category} • ${transaction.paymentMethod}',

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,

                children: [
                  Text(
                    '${isIncome ? '+' : '-'}₹${_formatAmount(transaction.amount)}',

                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _formatDate(transaction.date),

                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  purple.withValues(alpha: 0.10),
            ),

            child: const Icon(
              Icons.receipt_long_outlined,
              color: lightPurple,
              size: 38,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No Transactions Found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Try changing your filters or add a new transaction.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION DETAILS
  // ============================================================

  void _showTransactionDetails(
    TransactionModel transaction,
    FinanceProvider finance,
  ) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? green : red;

    showModalBottomSheet(
      context: context,

      backgroundColor: cardColor,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              14,
              22,
              30,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  width: 45,
                  height: 4,

                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: 65,
                  height: 65,

                  decoration: BoxDecoration(
                    color:
                        color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Icon(
                    _categoryIcon(
                      transaction.category,
                    ),
                    color: color,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  transaction.title,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${isIncome ? '+' : '-'}₹${_formatAmount(transaction.amount)}',

                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 25),

                _detailRow(
                  Icons.category_outlined,
                  'Category',
                  transaction.category,
                ),

                _detailRow(
                  Icons.payment_outlined,
                  'Payment Method',
                  transaction.paymentMethod,
                ),

                _detailRow(
                  Icons.calendar_today_outlined,
                  'Date',
                  _formatFullDate(transaction.date),
                ),

                _detailRow(
                  isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  'Type',
                  isIncome ? 'Income' : 'Expense',
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      _showDeleteDialog(
                        transaction,
                        finance,
                      );
                    },

                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      side: BorderSide(
                        color:
                            red.withValues(alpha: 0.45),
                      ),

                      foregroundColor: red,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),

                    icon: const Icon(
                      Icons.delete_outline_rounded,
                    ),

                    label: const Text(
                      'Delete Transaction',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color:
            Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: lightPurple,
            size: 18,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<bool> _confirmDelete(
    TransactionModel transaction,
  ) async {
    final result = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Delete Transaction?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "${transaction.title}"?',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showDeleteDialog(
    TransactionModel transaction,
    FinanceProvider finance,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Delete Transaction?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),

          content: const Text(
            'This action cannot be undone.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                finance.deleteTransaction(
                  transaction.id,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${transaction.title} deleted',
                    ),
                    backgroundColor:
                        const Color(0xFF1B263B),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
              ),

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FILTER LOGIC
  // ============================================================

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> transactions,
  ) {
    List<TransactionModel> filtered =
        List.from(transactions);

    // SEARCH

    final query =
        _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where(
        (transaction) {
          return transaction.title
                  .toLowerCase()
                  .contains(query) ||
              transaction.category
                  .toLowerCase()
                  .contains(query) ||
              transaction.paymentMethod
                  .toLowerCase()
                  .contains(query);
        },
      ).toList();
    }

    // TYPE FILTER

    if (_selectedType == 'Income') {
      filtered = filtered
          .where((transaction) => transaction.isIncome)
          .toList();
    }

    if (_selectedType == 'Expense') {
      filtered = filtered
          .where((transaction) => !transaction.isIncome)
          .toList();
    }

    // CATEGORY FILTER

    if (_selectedCategory != 'All') {
      filtered = filtered.where(
        (transaction) {
          return transaction.category
              .toLowerCase()
              .contains(
                _selectedCategory.toLowerCase(),
              );
        },
      ).toList();
    }

    // SORTING

    switch (_sortBy) {
      case 'Newest':
        filtered.sort(
          (a, b) => b.date.compareTo(a.date),
        );
        break;

      case 'Oldest':
        filtered.sort(
          (a, b) => a.date.compareTo(b.date),
        );
        break;

      case 'Highest':
        filtered.sort(
          (a, b) => b.amount.compareTo(a.amount),
        );
        break;

      case 'Lowest':
        filtered.sort(
          (a, b) => a.amount.compareTo(b.amount),
        );
        break;
    }

    return filtered;
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;

      case 'transport':
        return Icons.directions_car_outlined;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'bills':
        return Icons.receipt_long_outlined;

      case 'entertainment':
        return Icons.movie_outlined;

      case 'health':
        return Icons.favorite_outline_rounded;

      case 'education':
        return Icons.school_outlined;

      case 'salary':
        return Icons.account_balance_outlined;

      case 'freelance':
        return Icons.laptop_mac_outlined;

      case 'business':
        return Icons.business_center_outlined;

      case 'investment':
        return Icons.trending_up_rounded;

      case 'bonus':
        return Icons.card_giftcard_outlined;

      default:
        return Icons.payments_outlined;
    }
  }

  // ============================================================
  // FORMATTERS
  // ============================================================

  String _formatAmount(double amount) {
    return amount
        .round()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _formatCompact(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    }

    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }

    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final difference =
        DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(
          DateTime(
            date.year,
            date.month,
            date.day,
          ),
        ).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}