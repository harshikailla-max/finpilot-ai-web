import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ai_financial_orb.dart';

import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'budget_screen.dart';
import 'goal_screen.dart';
import 'investment_screen.dart';
import 'ai_insights_screen.dart';
import 'ai_coach_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'savings_planner_screen.dart';
import 'receipt_scanner_screen.dart';
import 'bank_statement_import_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Primary mobile screens
  late final List<Widget> _mobileScreens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const AiCoachScreen(),
    const GoalScreen(),
    const ProfileScreen(),
  ];

  // Desktop sidebar selection index
  int _desktopSelectedIndex = 0;

  late final List<Widget> _desktopScreens = [
    const DashboardScreen(), // 0: Dashboard
    const TransactionsScreen(), // 1: Analytics / Transactions
    const SavingsPlannerScreen(), // 2: Financial Health & Simulator
    const BudgetScreen(), // 3: Budget
    const GoalScreen(), // 4: Goals
    const InvestmentScreen(), // 5: Investments
    const AiCoachScreen(), // 6: AI Coach
    const AIInsightsScreen(), // 7: AI Insights
    const ReceiptScannerScreen(), // 8: Receipt Scanner
    const BankStatementImportScreen(), // 9: Bank Statement
    const ProfileScreen(), // 10: Profile
    const SettingsScreen(), // 11: Settings
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return _buildDesktopLayout();
        }

        return _buildMobileLayout();
      },
    );
  }

  // ============================================================
  // MOBILE NAVIGATION LAYOUT
  // ============================================================

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _mobileScreens,
      ),
      bottomNavigationBar: _buildMobileBottomNav(),
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMobileNavItem(
                index: 0,
                icon: Icons.dashboard_rounded,
                label: 'HOME',
              ),
              _buildMobileNavItem(
                index: 1,
                icon: Icons.account_balance_wallet_rounded,
                label: 'MONEY',
              ),
              // Central elevated AI Orb Button
              _buildCentralAiButton(),
              _buildMobileNavItem(
                index: 3,
                icon: Icons.flag_rounded,
                label: 'GOALS',
              ),
              _buildMobileNavItem(
                index: 4,
                icon: Icons.person_rounded,
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.cyan : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.white : AppTheme.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralAiButton() {
    final isSelected = _selectedIndex == 2;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.purple, AppTheme.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.purple.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: AiFinancialOrb(size: 32, isPulsing: true),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP LUXURY SIDEBAR LAYOUT
  // ============================================================

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // Permanent Luxury Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: AppTheme.background2,
              border: Border(
                right: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        const AiFinancialOrb(size: 34),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FINPILOT AI',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Financial OS Active',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),

                  // Navigation Scroll Area
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      children: [
                        _buildSidebarSectionTitle('OVERVIEW'),
                        _buildSidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
                        _buildSidebarItem(1, Icons.analytics_outlined, 'Analytics'),
                        _buildSidebarItem(2, Icons.health_and_safety_outlined, 'Financial Health'),

                        const SizedBox(height: 14),
                        _buildSidebarSectionTitle('MONEY'),
                        _buildSidebarItem(1, Icons.receipt_long_rounded, 'Transactions'),
                        _buildSidebarItem(3, Icons.pie_chart_outline_rounded, 'Budget Planner'),
                        _buildSidebarItem(4, Icons.flag_rounded, 'Financial Goals'),

                        const SizedBox(height: 14),
                        _buildSidebarSectionTitle('GROWTH'),
                        _buildSidebarItem(5, Icons.trending_up_rounded, 'AI Investment'),
                        _buildSidebarItem(2, Icons.auto_graph_rounded, 'Future Simulator'),

                        const SizedBox(height: 14),
                        _buildSidebarSectionTitle('INTELLIGENCE'),
                        _buildSidebarItem(6, Icons.smart_toy_outlined, 'AI Coach', isAi: true),
                        _buildSidebarItem(7, Icons.auto_awesome_rounded, 'AI Insights'),

                        const SizedBox(height: 14),
                        _buildSidebarSectionTitle('TOOLS'),
                        _buildSidebarItem(8, Icons.document_scanner_rounded, 'Receipt Scanner'),
                        _buildSidebarItem(9, Icons.upload_file_rounded, 'Bank Statement'),

                        const SizedBox(height: 14),
                        _buildSidebarSectionTitle('ACCOUNT'),
                        _buildSidebarItem(10, Icons.person_rounded, 'Private Profile'),
                        _buildSidebarItem(11, Icons.settings_rounded, 'Settings'),
                      ],
                    ),
                  ),

                  // Bottom User Info Pill
                  Container(
                    margin: const EdgeInsets.all(14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.purple,
                          child: Text('H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Harshika', style: TextStyle(color: AppTheme.white, fontSize: 12, fontWeight: FontWeight.w700)),
                              Text('Private Wealth', style: TextStyle(color: AppTheme.cyan, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main View Content
          Expanded(
            child: IndexedStack(
              index: _desktopSelectedIndex,
              children: _desktopScreens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label, {bool isAi = false}) {
    final isSelected = _desktopSelectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _desktopSelectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAi ? AppTheme.purple.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected && isAi
              ? Border.all(color: AppTheme.purple.withValues(alpha: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isAi ? AppTheme.cyan : Colors.white)
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isAi)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.purple, AppTheme.cyan]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'COPILOT',
                  style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
      ),
    );
  }
}