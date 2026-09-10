import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF111C2E);
  static const Color purple = Color(0xFF7B61FF);
  static const Color cyan = Color(0xFF4CC9F0);

  String userName = 'Harshika';
  String email = 'harshika@finpilot.ai';
  String phone = '+91 98765 43210';
  String occupation = 'Student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: const Icon(
              Icons.edit_outlined,
              color: cyan,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(),

          const SizedBox(height: 25),

          _buildFinancialScore(),

          const SizedBox(height: 25),

          _sectionTitle('PERSONAL INFORMATION'),

          const SizedBox(height: 12),

          _profileTile(
            icon: Icons.person_outline_rounded,
            title: 'Full Name',
            value: userName,
          ),

          _profileTile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            value: email,
          ),

          _profileTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            value: phone,
          ),

          _profileTile(
            icon: Icons.work_outline_rounded,
            title: 'Occupation',
            value: occupation,
          ),

          const SizedBox(height: 25),

          _sectionTitle('FINANCIAL OVERVIEW'),

          const SizedBox(height: 12),

          _buildFinancialGrid(),

          const SizedBox(height: 25),

          _sectionTitle('ACHIEVEMENTS'),

          const SizedBox(height: 12),

          _buildAchievement(
            icon: Icons.local_fire_department_rounded,
            title: '7 Day Streak',
            subtitle: 'Tracked your finances for 7 days',
            unlocked: true,
          ),

          _buildAchievement(
            icon: Icons.savings_rounded,
            title: 'Smart Saver',
            subtitle: 'Saved more than ₹25,000',
            unlocked: true,
          ),

          _buildAchievement(
            icon: Icons.track_changes_rounded,
            title: 'Goal Getter',
            subtitle: 'Complete your first savings goal',
            unlocked: false,
          ),

          const SizedBox(height: 25),

          _sectionTitle('ACCOUNT'),

          const SizedBox(height: 12),

          _actionTile(
            icon: Icons.history_rounded,
            title: 'Financial Activity',
            subtitle: 'View your transaction history',
            onTap: () {
              final finance = Provider.of<FinanceProvider>(context, listen: false);
              final total = finance.totalTransactions;
              final income = finance.totalIncome;
              final expense = finance.totalExpense;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Financial Activity', style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _activityRow('Total Transactions', '$total recorded'),
                      _activityRow('Total Income', '₹${income.toStringAsFixed(2)}'),
                      _activityRow('Total Expenses', '₹${expense.toStringAsFixed(2)}'),
                      _activityRow('Net Balance', '₹${(income - expense).toStringAsFixed(2)}'),
                      _activityRow('Savings Rate', '${finance.savingsRate.toStringAsFixed(1)}%'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(color: cyan)),
                    ),
                  ],
                ),
              );
            },
          ),

          _actionTile(
            icon: Icons.download_rounded,
            title: 'Export Financial Data',
            subtitle: 'Download all transactions as CSV',
            onTap: () async {
              final finance = Provider.of<FinanceProvider>(context, listen: false);
              final csv = await finance.exportToCsv();
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Row(
                    children: [
                      Icon(Icons.file_download_done_rounded, color: cyan),
                      SizedBox(width: 8),
                      Text('CSV Export', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${finance.totalTransactions} transactions compiled to CSV.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
                        child: SingleChildScrollView(
                          child: Text(
                            csv.isEmpty ? 'No transactions.' : csv,
                            style: const TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(color: Colors.white54)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: purple),
                      icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                      label: const Text('Copy CSV', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: csv));
                        Navigator.pop(ctx);
                        _showSnackBar('CSV copied to clipboard!');
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          _actionTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            danger: true,
            onTap: _showDeleteDialog,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            purple.withValues(alpha: 0.30),
            cyan.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [purple, cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.45),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 55,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: background,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            email,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: cyan.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: cyan,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'FinPilot AI Member',
                  style: TextStyle(
                    color: cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialScore() {
    const score = 82;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 90,
            width: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 9,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(cyan),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '82',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Health',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Great progress! Your finances are looking healthy.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: cyan,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          _iconBox(icon),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialGrid() {
    return Row(
      children: [
        Expanded(
          child: _financialCard(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Balance',
            value: '₹48.5K',
            color: cyan,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _financialCard(
            icon: Icons.savings_rounded,
            label: 'Savings',
            value: '₹35K',
            color: Colors.greenAccent,
          ),
        ),
      ],
    );
  }

  Widget _financialCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),

          const SizedBox(height: 15),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: unlocked
            ? cardColor
            : Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked
              ? purple.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: unlocked
                  ? purple.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: unlocked ? cyan : Colors.white24,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            unlocked
                ? Icons.verified_rounded
                : Icons.lock_outline_rounded,
            color: unlocked ? cyan : Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final iconColor = danger ? Colors.redAccent : cyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: danger
              ? Colors.redAccent.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: _iconBox(
          icon,
          color: iconColor,
          danger: danger,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: danger ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: danger ? Colors.redAccent : Colors.white38,
        ),
      ),
    );
  }

  Widget _iconBox(
    IconData icon, {
    Color color = cyan,
    bool danger = false,
  }) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: danger
            ? Colors.redAccent.withValues(alpha: 0.10)
            : purple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: color,
        size: 23,
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phone);
    final occupationController = TextEditingController(text: occupation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: nameController,
                  label: 'Full Name',
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: emailController,
                  label: 'Email',
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: phoneController,
                  label: 'Phone',
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: occupationController,
                  label: 'Occupation',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  userName = nameController.text.trim().isEmpty
                      ? userName
                      : nameController.text.trim();

                  email = emailController.text.trim().isEmpty
                      ? email
                      : emailController.text.trim();

                  phone = phoneController.text.trim().isEmpty
                      ? phone
                      : phoneController.text.trim();

                  occupation = occupationController.text.trim().isEmpty
                      ? occupation
                      : occupationController.text.trim();
                });

                Navigator.pop(context);

                _showSnackBar('Profile updated successfully!');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyan),
        ),
      ),
    );
  }


  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete All Data?',
            style: TextStyle(color: Colors.redAccent),
          ),
          content: const Text(
            'This will permanently delete all your transactions, goals, budgets, and investments from local storage. This action cannot be undone.',
            style: TextStyle(
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final finance = Provider.of<FinanceProvider>(context, listen: false);
                await finance.clearAllData();
                if (mounted) Navigator.pop(ctx);
                _showSnackBar('All financial data deleted successfully');
              },
              child: const Text('Delete Everything'),
            ),
          ],
        );
      },
    );
  }

  Widget _activityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}