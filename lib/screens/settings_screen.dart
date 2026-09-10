import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF111C2E);
  static const Color purple = Color(0xFF7B61FF);
  static const Color cyan = Color(0xFF4CC9F0);

  bool _notifications = true;
  bool _biometric = true;
  bool _darkMode = true;
  bool _aiSuggestions = true;
  bool _monthlyReport = true;

  String _userName = 'Alex Johnson';
  String _userEmail = 'alex.johnson@finpilot.ai';
  String _userPhone = '+91 98765 43210';
  String _userCurrency = '₹';
  String _aiTone = 'Balanced';
  String _aiRisk = 'Moderate';

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final storage = await StorageService.getInstance();
    final profile = await storage.loadUserProfile();
    final aiPrefs = await storage.loadAiPreferences();

    if (mounted) {
      setState(() {
        _userName = profile['name'] ?? 'Alex Johnson';
        _userEmail = profile['email'] ?? 'alex.johnson@finpilot.ai';
        _userPhone = profile['phone'] ?? '+91 98765 43210';
        _userCurrency = profile['currency'] ?? '₹';

        _aiTone = aiPrefs['tone'] ?? 'Balanced';
        _aiRisk = aiPrefs['riskTolerance'] ?? 'Moderate';
        _notifications = aiPrefs['notifications'] != 'false';
        _monthlyReport = aiPrefs['monthlyReport'] != 'false';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),

          const SizedBox(height: 28),

          _sectionTitle('Account'),
          const SizedBox(height: 12),

          _settingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            subtitle: '$_userName • $_userCurrency preferred',
            onTap: _showPersonalInfoSheet,
          ),

          _settingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Bank Accounts',
            subtitle: 'Manage bank accounts and linked sources',
            onTap: () => _showBankAccountsSheet(finance),
          ),

          _settingsTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            subtitle: 'UPI, Cards, Cash, and Net Banking breakdown',
            onTap: () => _showPaymentMethodsSheet(finance),
          ),

          const SizedBox(height: 25),

          _sectionTitle('Preferences'),
          const SizedBox(height: 12),

          _switchTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Get alerts about your daily finances & budgets',
            value: _notifications,
            onChanged: (value) async {
              setState(() => _notifications = value);
              final storage = await StorageService.getInstance();
              final prefs = await storage.loadAiPreferences();
              prefs['notifications'] = value.toString();
              await storage.saveAiPreferences(prefs);
            },
          ),

          _switchTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or device security unlock',
            value: _biometric,
            onChanged: (value) {
              setState(() => _biometric = value);
            },
          ),

          _switchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'FinPilot high-contrast dark theme (active)',
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
            },
          ),

          const SizedBox(height: 25),

          _sectionTitle('FinPilot AI'),
          const SizedBox(height: 12),

          _switchTile(
            icon: Icons.auto_awesome_rounded,
            title: 'AI Smart Suggestions',
            subtitle: 'Proactive spending pattern and leak insights',
            value: _aiSuggestions,
            onChanged: (value) {
              setState(() => _aiSuggestions = value);
            },
          ),

          _switchTile(
            icon: Icons.analytics_outlined,
            title: 'Monthly AI Report',
            subtitle: 'Generate end-of-month financial summaries',
            value: _monthlyReport,
            onChanged: (value) async {
              setState(() => _monthlyReport = value);
              final storage = await StorageService.getInstance();
              final prefs = await storage.loadAiPreferences();
              prefs['monthlyReport'] = value.toString();
              await storage.saveAiPreferences(prefs);
            },
          ),

          _settingsTile(
            icon: Icons.psychology_outlined,
            title: 'AI Preferences',
            subtitle: 'Tone: $_aiTone • Risk: $_aiRisk',
            onTap: _showAiPreferencesSheet,
          ),

          const SizedBox(height: 25),

          _sectionTitle('Security & Privacy'),
          const SizedBox(height: 12),

          _settingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'App Security PIN',
            subtitle: 'Configure local 4-digit security PIN',
            onTap: _showPinDialog,
          ),

          _settingsTile(
            icon: Icons.security_rounded,
            title: 'Privacy Guarantee',
            subtitle: '100% on-device processing • zero server upload',
            onTap: _showPrivacyDialog,
          ),

          const SizedBox(height: 25),

          _sectionTitle('Data Management'),
          const SizedBox(height: 12),

          _settingsTile(
            icon: Icons.file_download_outlined,
            title: 'Export Data to CSV',
            subtitle: 'Export ${finance.totalTransactions} transactions to standard CSV',
            onTap: () => _handleExportCsv(finance),
          ),

          _settingsTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Delete Imported Statements',
            subtitle: 'Remove transactions imported from bank files',
            onTap: () => _showDeleteImportedDialog(finance),
          ),

          _settingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Clear All Financial Data',
            subtitle: 'Permanently wipe all transactions, goals & budgets',
            danger: true,
            onTap: () => _showClearAllDataDialog(finance),
          ),

          const SizedBox(height: 25),

          _sectionTitle('Support & About'),
          const SizedBox(height: 12),

          _settingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center & FAQ',
            subtitle: 'Learn about OCR, Bank Import & AI Calculators',
            onTap: _showHelpCenterSheet,
          ),

          _settingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About FinPilot AI',
            subtitle: 'Version 1.0.0 (Production Build)',
            onTap: _showAboutDialog,
          ),

          const SizedBox(height: 30),

          _buildLogoutButton(),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'FinPilot AI • Safe, Local & Private',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            purple.withValues(alpha: 0.25),
            cyan.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [purple, cyan],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
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
        title.toUpperCase(),
        style: const TextStyle(
          color: cyan,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: danger
              ? Colors.redAccent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: danger
                ? Colors.redAccent.withValues(alpha: 0.15)
                : purple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: danger ? Colors.redAccent : cyan,
            size: 23,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: danger ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
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

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: cyan,
            size: 23,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: purple,
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white12,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.30),
          ),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PERSONAL INFO SHEET
  // ============================================================

  void _showPersonalInfoSheet() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);
    String selectedCurrency = _userCurrency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(nameCtrl, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(emailCtrl, 'Email Address', Icons.email_outlined),
                  const SizedBox(height: 12),
                  _field(phoneCtrl, 'Phone Number', Icons.phone_outlined),
                  const SizedBox(height: 14),
                  const Text(
                    'Preferred Currency',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['₹', '\$', '€', '£'].map((c) {
                      final selected = selectedCurrency == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(
                            '$c ${c == '₹' ? 'INR' : c == '\$' ? 'USD' : c == '€' ? 'EUR' : 'GBP'}',
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: selected,
                          selectedColor: purple,
                          backgroundColor: background,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedCurrency = c);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final storage = await StorageService.getInstance();
                        final profile = {
                          'name': nameCtrl.text.trim().isEmpty ? _userName : nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim().isEmpty ? _userEmail : emailCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim().isEmpty ? _userPhone : phoneCtrl.text.trim(),
                          'currency': selectedCurrency,
                        };
                        await storage.saveUserProfile(profile);
                        setState(() {
                          _userName = profile['name']!;
                          _userEmail = profile['email']!;
                          _userPhone = profile['phone']!;
                          _userCurrency = profile['currency']!;
                        });
                        if (mounted) Navigator.pop(ctx);
                        _showNotification('Profile updated successfully');
                      },
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BANK ACCOUNTS SHEET
  // ============================================================

  void _showBankAccountsSheet(FinanceProvider finance) {
    final bankTx = finance.transactions.where((t) => t.paymentMethod.toLowerCase().contains('bank') || t.source == 'bank_statement').toList();
    final bankIncome = bankTx.where((t) => t.isIncome).fold<double>(0.0, (s, t) => s + t.amount);
    final bankExpense = bankTx.where((t) => !t.isIncome).fold<double>(0.0, (s, t) => s + t.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_rounded, color: cyan),
                  SizedBox(width: 10),
                  Text(
                    'Connected Bank Accounts',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Accounts detected from your imported statements & transactions',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Primary Savings Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('ACTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bank Activity', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('${bankTx.length} transactions', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Credits / Debits', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('+₹${bankIncome.toStringAsFixed(0)} / -₹${bankExpense.toStringAsFixed(0)}', style: const TextStyle(color: cyan, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
                  label: const Text('Import Bank Statement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/bank_statement_import');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PAYMENT METHODS SHEET
  // ============================================================

  void _showPaymentMethodsSheet(FinanceProvider finance) {
    final Map<String, int> counts = {};
    final Map<String, double> totals = {};

    for (final t in finance.transactions) {
      final method = t.paymentMethod.trim().isEmpty ? 'Other' : t.paymentMethod.trim();
      counts[method] = (counts[method] ?? 0) + 1;
      totals[method] = (totals[method] ?? 0) + t.amount;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: cyan),
                  SizedBox(width: 10),
                  Text(
                    'Active Payment Methods',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Distribution of your expenses and receipts',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (counts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No transaction methods recorded yet', style: TextStyle(color: Colors.white54))),
                )
              else
                ...counts.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            entry.key.toLowerCase().contains('upi')
                                ? Icons.qr_code_rounded
                                : entry.key.toLowerCase().contains('card')
                                    ? Icons.credit_card_rounded
                                    : entry.key.toLowerCase().contains('bank')
                                        ? Icons.account_balance_rounded
                                        : Icons.payments_outlined,
                            color: cyan,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              Text('${entry.value} transaction(s)', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        Text(
                          '₹${(totals[entry.key] ?? 0).toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // AI PREFERENCES SHEET
  // ============================================================

  void _showAiPreferencesSheet() {
    String currentTone = _aiTone;
    String currentRisk = _aiRisk;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_rounded, color: purple),
                      SizedBox(width: 10),
                      Text(
                        'AI Financial Copilot Tuning',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Copilot Tone', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: ['Direct', 'Balanced', 'Analytical', 'Encouraging'].map((tone) {
                      final selected = currentTone == tone;
                      return ChoiceChip(
                        label: Text(tone, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
                        selected: selected,
                        selectedColor: purple,
                        backgroundColor: background,
                        onSelected: (val) {
                          if (val) setModalState(() => currentTone = tone);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Investment Risk Profile', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: ['Conservative', 'Moderate', 'Aggressive'].map((risk) {
                      final selected = currentRisk == risk;
                      return ChoiceChip(
                        label: Text(risk, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
                        selected: selected,
                        selectedColor: cyan,
                        backgroundColor: background,
                        onSelected: (val) {
                          if (val) setModalState(() => currentRisk = risk);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () async {
                        final storage = await StorageService.getInstance();
                        final prefs = await storage.loadAiPreferences();
                        prefs['tone'] = currentTone;
                        prefs['riskTolerance'] = currentRisk;
                        await storage.saveAiPreferences(prefs);
                        setState(() {
                          _aiTone = currentTone;
                          _aiRisk = currentRisk;
                        });
                        if (mounted) Navigator.pop(ctx);
                        _showNotification('AI preferences configured');
                      },
                      child: const Text('Apply AI Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SECURITY PIN DIALOG
  // ============================================================

  void _showPinDialog() async {
    final storage = await StorageService.getInstance();
    final currentPin = await storage.loadSecurityPin();
    final pinCtrl = TextEditingController();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(currentPin == null ? 'Set App PIN' : 'Update App PIN', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentPin == null ? 'Enter a 4-digit security PIN for biometric lock fallback.' : 'Enter a new 4-digit PIN to replace your current PIN.',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinCtrl,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: purple),
              onPressed: () async {
                if (pinCtrl.text.length != 4) {
                  _showNotification('Please enter a valid 4-digit PIN');
                  return;
                }
                await storage.saveSecurityPin(pinCtrl.text);
                if (mounted) Navigator.pop(ctx);
                _showNotification('Security PIN updated successfully');
              },
              child: const Text('Save PIN', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRIVACY GUARANTEE DIALOG
  // ============================================================

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.greenAccent),
              SizedBox(width: 10),
              Text('Privacy Guarantee', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FinPilot AI is built strictly offline-first:\n',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '• 100% Local Storage: All financial data, receipts, and statement logs stay in local storage.\n\n'
                  '• On-Device ML OCR: Receipt processing uses Google ML Kit running on your phone’s CPU/GPU without cloud APIs.\n\n'
                  '• Zero Telemetry of Financial Data: We never upload or share bank statements, balances, or transaction details.\n\n'
                  '• Full Data Ownership: You can export your data to CSV or wipe it permanently at any time.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood', style: TextStyle(color: cyan)),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DATA MANAGEMENT: EXPORT CSV
  // ============================================================

  void _handleExportCsv(FinanceProvider finance) async {
    final csvContent = await finance.exportToCsv();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.file_download_done_rounded, color: cyan),
              SizedBox(width: 10),
              Text('Export CSV Ready', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Successfully compiled ${finance.totalTransactions} transactions to standard RFC 4180 CSV format.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvContent.isEmpty ? 'No transactions to export.' : csvContent,
                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                  ),
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
              icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
              label: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: csvContent));
                Navigator.pop(ctx);
                _showNotification('CSV copied to clipboard!');
              },
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DATA MANAGEMENT: DELETE IMPORTED
  // ============================================================

  void _showDeleteImportedDialog(FinanceProvider finance) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Imported Statements?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'This will delete all transactions imported from bank statements (CSV/Excel/PDF). Manually added transactions and receipts will be kept.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                await finance.deleteImportedTransactions();
                if (mounted) Navigator.pop(ctx);
                _showNotification('Imported transactions deleted');
              },
              child: const Text('Delete Imported', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DATA MANAGEMENT: CLEAR ALL
  // ============================================================

  void _showClearAllDataDialog(FinanceProvider finance) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Clear All Data?', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
          content: const Text(
            'This action is IRREVERSIBLE. It will delete all transactions, budgets, goals, debts, and investments from local storage.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                await finance.clearAllData();
                if (mounted) Navigator.pop(ctx);
                _showNotification('All data cleared successfully');
              },
              child: const Text('Wipe Everything', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HELP CENTER SHEET
  // ============================================================

  void _showHelpCenterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: cyan),
                    SizedBox(width: 10),
                    Text('Help Center & Guide', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                _helpItem(
                  'How does receipt scanning work?',
                  'FinPilot uses Google ML Kit OCR running directly on your phone. It detects the merchant name, total bill amount, date, taxes, and automatically categorizes the purchase.',
                ),
                _helpItem(
                  'How does Bank Statement Import work?',
                  'You can import CSV, Excel (.xlsx), or PDF statements. FinPilot automatically identifies Date, Description, and Debit/Credit columns and warns you of any duplicate transactions before importing.',
                ),
                _helpItem(
                  'How is Financial Health Score calculated?',
                  'Your 0-100 score is computed from 4 weighted pillars: Savings Rate (30%), Expense-to-Income Ratio (30%), Debt Burden (20%), and Emergency Fund Coverage (20%).',
                ),
                _helpItem(
                  'What is the Car Affordability Engine?',
                  'It applies the standard 20/4/10 financial rule (20% down payment, max 4-year tenure, max 10% monthly income for all car expenses) to tell you if a car purchase is safe.',
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _helpItem(String title, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Text(answer, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: cyan, size: 20),
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: cyan),
              SizedBox(width: 10),
              Text('FinPilot AI', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Your intelligent personal finance copilot.\n\n'
            '• Real on-device OCR receipt scanner\n'
            '• Automated CSV, Excel & PDF statement parsing\n'
            '• Offline duplicate transaction detection\n'
            '• Real financial calculators & savings projections\n'
            '• 100% private and offline-first storage.',
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: cyan)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Log Out?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to log out of FinPilot AI? Your local financial records remain securely stored on this device.',
            style: TextStyle(color: Colors.white60),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                _showNotification('Logged out successfully');
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
