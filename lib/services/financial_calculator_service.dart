import 'dart:math' as math;
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';

class CarAffordabilityResult {
  final double carPrice;
  final double currentSavings;
  final double downPayment;
  final double loanPrincipal;
  final int targetMonths;
  final double monthlySavingsRequired;
  final double estimatedEmi;
  final double totalMonthlyCommitment;
  final double debtToIncomeRatio; // percentage
  final int affordabilityScore; // 0 - 100
  final bool isFeasible;
  final String recommendation;

  CarAffordabilityResult({
    required this.carPrice,
    required this.currentSavings,
    required this.downPayment,
    required this.loanPrincipal,
    required this.targetMonths,
    required this.monthlySavingsRequired,
    required this.estimatedEmi,
    required this.totalMonthlyCommitment,
    required this.debtToIncomeRatio,
    required this.affordabilityScore,
    required this.isFeasible,
    required this.recommendation,
  });
}

class MoneyLeakItem {
  final String category;
  final String title;
  final double monthlySpending;
  final int frequency;
  final double potentialMonthlySaving;
  final String tip;

  MoneyLeakItem({
    required this.category,
    required this.title,
    required this.monthlySpending,
    required this.frequency,
    required this.potentialMonthlySaving,
    required this.tip,
  });
}

class DetectedSubscription {
  final String merchant;
  final double amount;
  final String frequency; // 'Monthly', 'Annual'
  final double monthlyCost;
  final double annualCost;
  final DateTime nextExpectedPayment;

  DetectedSubscription({
    required this.merchant,
    required this.amount,
    required this.frequency,
    required this.monthlyCost,
    required this.annualCost,
    required this.nextExpectedPayment,
  });
}

class TaxCalculationResult {
  final double grossIncome;
  final double totalDeductions;
  final double taxableIncome;
  final double estimatedTax;
  final double effectiveTaxRate;
  final List<String> taxSavingOpportunities;
  final String regimeName;

  TaxCalculationResult({
    required this.grossIncome,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.estimatedTax,
    required this.effectiveTaxRate,
    required this.taxSavingOpportunities,
    required this.regimeName,
  });
}

class FinancialCalculatorService {
  // ============================================================
  // CAR AFFORDABILITY (SECTION 26)
  // ============================================================

  static CarAffordabilityResult calculateCarAffordability({
    required double carPrice,
    required double currentSavings,
    required int targetMonths,
    required double downPaymentPercentage, // e.g. 20%
    required double annualInterestRate, // e.g. 9.5%
    required int loanTenureYears, // e.g. 5 years
    required double monthlyIncome,
    required double monthlyExpenses,
  }) {
    final downPayment = carPrice * (downPaymentPercentage / 100);
    final loanPrincipal = math.max(0.0, carPrice - downPayment);
    final loanTenureMonths = loanTenureYears * 12;

    // Monthly savings needed to accumulate downpayment
    final savingsDeficit = math.max(0.0, downPayment - currentSavings);
    final monthlySavingsRequired = targetMonths > 0 ? savingsDeficit / targetMonths : 0.0;

    // Loan EMI calculation
    double emi = 0.0;
    if (loanPrincipal > 0 && annualInterestRate > 0 && loanTenureMonths > 0) {
      final r = (annualInterestRate / 12) / 100;
      emi = (loanPrincipal * r * math.pow(1 + r, loanTenureMonths)) /
          (math.pow(1 + r, loanTenureMonths) - 1);
    } else if (loanTenureMonths > 0) {
      emi = loanPrincipal / loanTenureMonths;
    }

    final currentMonthlySavingsCapacity = math.max(0.0, monthlyIncome - monthlyExpenses);
    final totalMonthlyCommitment = monthlySavingsRequired + emi;
    final dti = monthlyIncome > 0 ? (emi / monthlyIncome) * 100 : 0.0;

    // Score: 0 - 100
    int score = 100;
    if (dti > 20) score -= ((dti - 20) * 2).toInt();
    if (monthlySavingsRequired > currentMonthlySavingsCapacity) {
      score -= 35;
    } else if (currentMonthlySavingsCapacity > 0) {
      final ratio = monthlySavingsRequired / currentMonthlySavingsCapacity;
      if (ratio > 0.7) score -= 15;
    }
    score = score.clamp(10, 100);

    final isFeasible = monthlySavingsRequired <= currentMonthlySavingsCapacity && dti <= 35;

    String recommendation;
    if (isFeasible) {
      recommendation =
          'Feasible! Your monthly capacity of ₹${currentMonthlySavingsCapacity.toStringAsFixed(0)} comfortably covers the required ₹${monthlySavingsRequired.toStringAsFixed(0)}/month down payment plan and EMI of ₹${emi.toStringAsFixed(0)}.';
    } else if (monthlySavingsRequired > currentMonthlySavingsCapacity) {
      final shortfall = monthlySavingsRequired - currentMonthlySavingsCapacity;
      recommendation =
          'Challenging. You have a monthly shortfall of ₹${shortfall.toStringAsFixed(0)}. Consider extending your timeline to ${(targetMonths * 1.5).ceil()} months or choosing a vehicle under ₹${((carPrice * currentMonthlySavingsCapacity) / monthlySavingsRequired).toStringAsFixed(0)}.';
    } else {
      recommendation =
          'Caution: The estimated EMI will consume ${dti.toStringAsFixed(1)}% of your monthly income (recommended max is 15-20%). Consider a larger down payment.';
    }

    return CarAffordabilityResult(
      carPrice: carPrice,
      currentSavings: currentSavings,
      downPayment: downPayment,
      loanPrincipal: loanPrincipal,
      targetMonths: targetMonths,
      monthlySavingsRequired: monthlySavingsRequired,
      estimatedEmi: emi,
      totalMonthlyCommitment: totalMonthlyCommitment,
      debtToIncomeRatio: dti,
      affordabilityScore: score,
      isFeasible: isFeasible,
      recommendation: recommendation,
    );
  }

  // ============================================================
  // FINANCIAL HEALTH SCORE (SECTION 30)
  // ============================================================

  static Map<String, dynamic> calculateFinancialHealth({
    required double monthlyIncome,
    required double monthlyExpenses,
    required double currentBalance,
    required double totalDebtEmi,
    required List<FinancialGoal> goals,
  }) {
    if (monthlyIncome <= 0) {
      return {
        'score': 50,
        'label': 'Average',
        'savingsRateScore': 10,
        'expenseControlScore': 10,
        'debtScore': 15,
        'emergencyScore': 5,
        'goalScore': 10,
      };
    }

    // 1. Savings rate (max 25 pts)
    final savings = math.max(0.0, monthlyIncome - monthlyExpenses);
    final savingsRate = (savings / monthlyIncome) * 100;
    int savingsScore = ((savingsRate / 30) * 25).clamp(0, 25).round();

    // 2. Expense control (max 20 pts)
    final expenseRatio = (monthlyExpenses / monthlyIncome) * 100;
    int expenseScore = 20;
    if (expenseRatio > 85) {
      expenseScore = 5;
    } else if (expenseRatio > 70) {
      expenseScore = 12;
    } else if (expenseRatio > 50) {
      expenseScore = 17;
    }

    // 3. Debt burden (max 15 pts)
    final dti = (totalDebtEmi / monthlyIncome) * 100;
    int debtScore = 15;
    if (dti > 40) {
      debtScore = 2;
    } else if (dti > 25) {
      debtScore = 8;
    } else if (dti > 15) {
      debtScore = 12;
    }

    // 4. Emergency Fund (max 20 pts)
    // 3 months of expenses is baseline
    final targetEmergency = monthlyExpenses * 3;
    int emergencyScore = targetEmergency > 0
        ? ((currentBalance / targetEmergency) * 20).clamp(0, 20).round()
        : 10;

    // 5. Goal Progress (max 20 pts)
    int goalScore = 10;
    if (goals.isNotEmpty) {
      final totalTarget = goals.fold<double>(0, (sum, g) => sum + g.targetAmount);
      final totalSaved = goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
      if (totalTarget > 0) {
        goalScore = ((totalSaved / totalTarget) * 20).clamp(0, 20).round();
      }
    }

    final totalScore = (savingsScore + expenseScore + debtScore + emergencyScore + goalScore).clamp(0, 100);

    String label = 'Poor';
    if (totalScore >= 80) {
      label = 'Excellent';
    } else if (totalScore >= 65) {
      label = 'Good';
    } else if (totalScore >= 50) {
      label = 'Moderate';
    }

    return {
      'score': totalScore,
      'label': label,
      'savingsRateScore': savingsScore,
      'expenseControlScore': expenseScore,
      'debtScore': debtScore,
      'emergencyScore': emergencyScore,
      'goalScore': goalScore,
      'savingsRate': savingsRate,
    };
  }

  // ============================================================
  // MONEY LEAK DETECTOR (SECTION 31)
  // ============================================================

  static List<MoneyLeakItem> detectMoneyLeaks(List<FinanceTransaction> transactions) {
    final expenses = transactions.where((t) => !t.isIncome).toList();
    if (expenses.isEmpty) return [];

    final List<MoneyLeakItem> leaks = [];

    // 1. Food Delivery / Dining
    final foodTx = expenses.where((t) => t.category.toLowerCase() == 'food').toList();
    if (foodTx.isNotEmpty) {
      final foodTotal = foodTx.fold<double>(0, (sum, t) => sum + t.amount);
      if (foodTx.length >= 5 || foodTotal > 5000) {
        leaks.add(MoneyLeakItem(
          category: 'Food & Dining',
          title: 'Frequent Dining / Orders',
          monthlySpending: foodTotal,
          frequency: foodTx.length,
          potentialMonthlySaving: foodTotal * 0.25,
          tip: 'Cooking at home 2 more days per week can save 25% on food bills.',
        ));
      }
    }

    // 2. Shopping Spikes
    final shopTx = expenses.where((t) => t.category.toLowerCase() == 'shopping').toList();
    if (shopTx.isNotEmpty) {
      final shopTotal = shopTx.fold<double>(0, (sum, t) => sum + t.amount);
      if (shopTotal > 4000) {
        leaks.add(MoneyLeakItem(
          category: 'Shopping',
          title: 'E-commerce Impulse Purchases',
          monthlySpending: shopTotal,
          frequency: shopTx.length,
          potentialMonthlySaving: shopTotal * 0.30,
          tip: 'Implement a 48-hour cooling rule before buying non-essential items.',
        ));
      }
    }

    // 3. Micro-transactions (under ₹300)
    final microTx = expenses.where((t) => t.amount <= 300).toList();
    if (microTx.length >= 8) {
      final microTotal = microTx.fold<double>(0, (sum, t) => sum + t.amount);
      leaks.add(MoneyLeakItem(
        category: 'Micro Expenses',
        title: 'Frequent Small UPI Payments',
        monthlySpending: microTotal,
        frequency: microTx.length,
        potentialMonthlySaving: microTotal * 0.35,
        tip: 'Small recurring payments go unnoticed but add up to significant amounts.',
      ));
    }

    // 4. Entertainment & Subscriptions
    final entTx = expenses.where((t) => t.category.toLowerCase() == 'entertainment').toList();
    if (entTx.isNotEmpty) {
      final entTotal = entTx.fold<double>(0, (sum, t) => sum + t.amount);
      if (entTotal > 1500) {
        leaks.add(MoneyLeakItem(
          category: 'Entertainment',
          title: 'Media & Streaming Services',
          monthlySpending: entTotal,
          frequency: entTx.length,
          potentialMonthlySaving: entTotal * 0.40,
          tip: 'Audit streaming services you haven’t watched in the past 30 days.',
        ));
      }
    }

    return leaks;
  }

  // ============================================================
  // SUBSCRIPTION DETECTOR (SECTION 32)
  // ============================================================

  static List<DetectedSubscription> detectSubscriptions(List<FinanceTransaction> transactions) {
    final expenses = transactions.where((t) => !t.isIncome).toList();
    final List<DetectedSubscription> subscriptions = [];

    final subscriptionKeywords = [
      'netflix',
      'spotify',
      'prime',
      'hotstar',
      'disney',
      'youtube',
      'apple',
      'icloud',
      'google one',
      'chatgpt',
      'gym',
      'cult',
      'broadband',
      'airtel',
      'jio',
    ];

    final Map<String, List<FinanceTransaction>> grouped = {};

    for (final tx in expenses) {
      final clean = tx.title.toLowerCase();
      for (final kw in subscriptionKeywords) {
        if (clean.contains(kw)) {
          grouped.putIfAbsent(kw, () => []).add(tx);
          break;
        }
      }
    }

    for (final entry in grouped.entries) {
      final kw = entry.key;
      final txList = entry.value;
      if (txList.isEmpty) continue;

      final latest = txList.first;
      final capitalized = kw[0].toUpperCase() + kw.substring(1);
      final monthly = latest.amount;
      final annual = monthly * 12;
      final nextDate = latest.date.add(const Duration(days: 30));

      subscriptions.add(DetectedSubscription(
        merchant: capitalized,
        amount: latest.amount,
        frequency: 'Monthly',
        monthlyCost: monthly,
        annualCost: annual,
        nextExpectedPayment: nextDate,
      ));
    }

    return subscriptions;
  }

  // ============================================================
  // INVESTMENT PLANNER (SECTION 28)
  // ============================================================

  /// Calculates accurate investment projections supporting:
  /// - SIP (Monthly Systematic Investment)
  /// - Lump Sum (One-Time Principal Investment)
  /// - Annual Step-Up SIP (e.g. 5%, 10% annual increase in SIP)
  /// - Inflation-Adjusted Real Returns (Purchasing Power)
  static Map<String, dynamic> calculateInvestmentProjections({
    required double monthlyInvestment,
    required int years,
    bool isLumpSum = false,
    double annualStepUpPercentage = 0.0,
    double inflationRate = 6.0,
    double? customExpectedReturnRate,
  }) {
    if (years <= 0 || monthlyInvestment <= 0) {
      return {
        'totalInvested': monthlyInvestment,
        'conservative': {'rate': 8.0, 'futureValue': monthlyInvestment, 'wealthGain': 0.0, 'realFutureValue': monthlyInvestment, 'realWealthGain': 0.0},
        'moderate': {'rate': 12.0, 'futureValue': monthlyInvestment, 'wealthGain': 0.0, 'realFutureValue': monthlyInvestment, 'realWealthGain': 0.0},
        'aggressive': {'rate': 15.0, 'futureValue': monthlyInvestment, 'wealthGain': 0.0, 'realFutureValue': monthlyInvestment, 'realWealthGain': 0.0},
        'disclaimer': 'Illustrative estimate only. Actual returns vary depending on market conditions.',
      };
    }

    Map<String, dynamic> calculateScenario(double annualRate) {
      double totalInvested = 0.0;
      double futureValue = 0.0;

      if (isLumpSum) {
        // One-time lump sum compounded annually
        totalInvested = monthlyInvestment;
        final r = annualRate / 100.0;
        futureValue = totalInvested * math.pow(1.0 + r, years);
      } else if (annualStepUpPercentage > 0) {
        // Step-Up SIP: Monthly investment increases every 12 months
        final monthlyRate = (annualRate / 100.0) / 12.0;
        double currentMonthly = monthlyInvestment;
        futureValue = 0.0;

        for (int y = 0; y < years; y++) {
          for (int m = 0; m < 12; m++) {
            totalInvested += currentMonthly;
            final remainingMonths = (years * 12) - (y * 12 + m);
            futureValue += currentMonthly * math.pow(1.0 + monthlyRate, remainingMonths);
          }
          currentMonthly *= (1.0 + annualStepUpPercentage / 100.0);
        }
      } else {
        // Standard regular monthly SIP
        final n = years * 12;
        totalInvested = monthlyInvestment * n;
        final r = (annualRate / 100.0) / 12.0;
        if (r > 0) {
          futureValue = monthlyInvestment * ((math.pow(1.0 + r, n) - 1.0) / r) * (1.0 + r);
        } else {
          futureValue = totalInvested;
        }
      }

      // Inflation adjustment: Real purchasing power = FV / (1 + inflation)^years
      final infFactor = math.pow(1.0 + (inflationRate / 100.0), years);
      final realFv = futureValue / infFactor;
      final realWealthGain = realFv - totalInvested;

      return {
        'rate': annualRate,
        'totalInvested': totalInvested,
        'futureValue': futureValue,
        'wealthGain': futureValue - totalInvested,
        'realFutureValue': realFv,
        'realWealthGain': realWealthGain,
      };
    }

    final conservative = calculateScenario(8.0);
    final moderate = calculateScenario(12.0);
    final aggressive = calculateScenario(15.0);

    final result = <String, dynamic>{
      'totalInvested': moderate['totalInvested'],
      'isLumpSum': isLumpSum,
      'annualStepUpPercentage': annualStepUpPercentage,
      'inflationRate': inflationRate,
      'conservative': conservative,
      'moderate': moderate,
      'aggressive': aggressive,
      'disclaimer': 'Illustrative estimate only. Actual returns vary depending on market conditions.',
    };

    if (customExpectedReturnRate != null && customExpectedReturnRate > 0) {
      result['custom'] = calculateScenario(customExpectedReturnRate);
    }

    return result;
  }

  // ============================================================
  // TAX SAVER MODE (SECTION 29)
  // ============================================================

  static TaxCalculationResult calculateTax({
    required double annualIncome,
    required double deduction80C, // max 1.5L
    required double healthInsurance80D, // max 25k/50k
    required double standardDeduction, // 50k / 75k
    required bool isNewRegime,
  }) {
    double totalDeductions = 0.0;
    double taxableIncome = annualIncome;
    double tax = 0.0;

    final List<String> opportunities = [];

    if (isNewRegime) {
      // New Tax Regime (India FY 2024-25 / 2025-26)
      // Standard deduction of 75,000
      totalDeductions = 75000;
      taxableIncome = math.max(0.0, annualIncome - totalDeductions);

      if (taxableIncome <= 300000) {
        tax = 0;
      } else if (taxableIncome <= 700000) {
        tax = (taxableIncome - 300000) * 0.05;
      } else if (taxableIncome <= 1000000) {
        tax = 20000 + (taxableIncome - 700000) * 0.10;
      } else if (taxableIncome <= 1200000) {
        tax = 50000 + (taxableIncome - 1000000) * 0.15;
      } else if (taxableIncome <= 1500000) {
        tax = 80000 + (taxableIncome - 1200000) * 0.20;
      } else {
        tax = 140000 + (taxableIncome - 1500000) * 0.30;
      }

      // Section 87A rebate for taxable income <= 7L
      if (taxableIncome <= 700000) {
        tax = 0.0;
      }

      opportunities.add('New regime provides lower slab rates and a ₹75,000 standard deduction.');
      if (annualIncome > 700000 && annualIncome < 1000000) {
        opportunities.add('Consider NPS (National Pension Scheme) employer contribution under Sec 80CCD(2).');
      }
    } else {
      // Old Tax Regime
      final capped80C = deduction80C.clamp(0.0, 150000.0);
      final capped80D = healthInsurance80D.clamp(0.0, 50000.0);
      totalDeductions = 50000 + capped80C + capped80D;
      taxableIncome = math.max(0.0, annualIncome - totalDeductions);

      if (taxableIncome <= 250000) {
        tax = 0;
      } else if (taxableIncome <= 500000) {
        tax = (taxableIncome - 250000) * 0.05;
      } else if (taxableIncome <= 1000000) {
        tax = 12500 + (taxableIncome - 500000) * 0.20;
      } else {
        tax = 112500 + (taxableIncome - 1000000) * 0.30;
      }

      if (taxableIncome <= 500000) {
        tax = 0.0;
      }

      if (capped80C < 150000) {
        opportunities.add('You have ₹${(150000 - capped80C).toStringAsFixed(0)} unused in Section 80C (PPF, ELSS, EPF).');
      }
      if (capped80D < 25000) {
        opportunities.add('You can claim up to ₹25,000 under Section 80D with health insurance.');
      }
    }

    final effectiveRate = annualIncome > 0 ? (tax / annualIncome) * 100 : 0.0;

    return TaxCalculationResult(
      grossIncome: annualIncome,
      totalDeductions: totalDeductions,
      taxableIncome: taxableIncome,
      estimatedTax: tax,
      effectiveTaxRate: effectiveRate,
      taxSavingOpportunities: opportunities,
      regimeName: isNewRegime ? 'New Tax Regime' : 'Old Tax Regime',
    );
  }

  // ============================================================
  // AI COPILOT ANSWER ENGINE (SECTION 25)
  // ============================================================

  static String answerCopilotQuery({
    required String question,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double currentBalance,
    required List<FinanceTransaction> transactions,
    required List<FinancialGoal> goals,
  }) {
    final q = question.toLowerCase();
    final monthlySavings = math.max(0.0, monthlyIncome - monthlyExpenses);

    // 1. "Can I buy a car in one year?"
    if (q.contains('car') || q.contains('vehicle')) {
      final res = calculateCarAffordability(
        carPrice: 1000000,
        currentSavings: currentBalance,
        targetMonths: 12,
        downPaymentPercentage: 20,
        annualInterestRate: 9.5,
        loanTenureYears: 5,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
      );
      return 'FinPilot Analysis for ₹10 Lakh Car:\n• 20% Down Payment: ₹${res.downPayment.toStringAsFixed(0)}\n• Monthly Savings Required: ₹${res.monthlySavingsRequired.toStringAsFixed(0)}/mo\n• Your Savings Capacity: ₹${monthlySavings.toStringAsFixed(0)}/mo\n• Estimated 5-Yr EMI: ₹${res.estimatedEmi.toStringAsFixed(0)}/mo\n\n${res.recommendation}';
    }

    // 2. "How much should I save every month?"
    if (q.contains('how much should i save') || q.contains('save every month') || q.contains('savings rate')) {
      final ideal20 = monthlyIncome * 0.20;
      final ideal30 = monthlyIncome * 0.30;
      return 'Based on the 50/30/20 financial rule for your ₹${monthlyIncome.toStringAsFixed(0)} income:\n• Recommended Savings (20%): ₹${ideal20.toStringAsFixed(0)}/month\n• Aggressive Wealth Target (30%): ₹${ideal30.toStringAsFixed(0)}/month\n• Your Current Surplus: ₹${monthlySavings.toStringAsFixed(0)}/month (${monthlyIncome > 0 ? ((monthlySavings / monthlyIncome) * 100).toStringAsFixed(1) : 0}%).\n\nAllocating ₹${(ideal20 * 0.5).toStringAsFixed(0)} to emergency fund and ₹${(ideal20 * 0.5).toStringAsFixed(0)} to investments is ideal.';
    }

    // 3. "Where am I spending too much?"
    if (q.contains('spending too much') || q.contains('where am i spending') || q.contains('highest expense')) {
      final catMap = <String, double>{};
      for (final t in transactions.where((t) => !t.isIncome)) {
        catMap[t.category] = (catMap[t.category] ?? 0) + t.amount;
      }
      if (catMap.isEmpty) {
        return 'No expense transactions found yet. Once you scan receipts or import bank statements, FinPilot will pinpoint spending leaks.';
      }
      final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      final topPercent = monthlyExpenses > 0 ? ((top.value / monthlyExpenses) * 100).toStringAsFixed(1) : '0';
      return 'Your largest spending area is "${top.key}" at ₹${top.value.toStringAsFixed(0)} ($topPercent% of total expenses).\n${sorted.length > 1 ? "Second largest: ${sorted[1].key} at ₹${sorted[1].value.toStringAsFixed(0)}." : ""} Reducing discretionary spending here will yield the fastest savings.';
    }

    // 4. "How much can I invest?"
    if (q.contains('invest') || q.contains('sip')) {
      final safeToInvest = monthlySavings * 0.70;
      return 'With your monthly surplus of ₹${monthlySavings.toStringAsFixed(0)}:\n• Safe Monthly SIP: ₹${safeToInvest.toStringAsFixed(0)}/month (70% of surplus)\n• Liquidity Buffer: ₹${(monthlySavings * 0.30).toStringAsFixed(0)}/month retained in cash/FD.\n\nA ₹${safeToInvest.toStringAsFixed(0)} monthly SIP at 12% annual return can grow to approximately ₹${((safeToInvest * 12 * 5) * 1.35).toStringAsFixed(0)} in 5 years (illustrative estimate).';
    }

    // 5. "Can I afford a ₹20,000 phone?"
    if (q.contains('phone') || q.contains('gadget') || q.contains('afford')) {
      final target = 20000.0;
      final canBuyOutright = currentBalance >= (target + monthlyExpenses * 2);
      final monthsToSave = monthlySavings > 0 ? (target / monthlySavings).ceil() : 0;
      if (canBuyOutright) {
        return 'Yes, you can comfortably afford this ₹20,000 purchase without dipping below your 2-month expense safety net.';
      } else if (monthlySavings > 0) {
        return 'It is feasible by setting aside savings over $monthsToSave month(s) (₹${monthlySavings.toStringAsFixed(0)}/mo), avoiding credit card debt or costly no-cost EMI penalties.';
      } else {
        return 'Not recommended right now. Your current expenses match or exceed income. Increase your monthly buffer before making discretionary purchases.';
      }
    }

    // 6. "How much do I need for an emergency fund?"
    if (q.contains('emergency fund') || q.contains('emergency')) {
      final months3 = monthlyExpenses * 3;
      final months6 = monthlyExpenses * 6;
      return 'Emergency Fund Target based on ₹${monthlyExpenses.toStringAsFixed(0)}/month expenses:\n• 3 Months (Minimum): ₹${months3.toStringAsFixed(0)}\n• 6 Months (Recommended): ₹${months6.toStringAsFixed(0)}\n• Current Available Balance: ₹${currentBalance.toStringAsFixed(0)}\n${currentBalance >= months6 ? "Your emergency fund is fully funded!" : "Gap to 6-month safety: ₹${math.max(0.0, months6 - currentBalance).toStringAsFixed(0)}."}';
    }

    // 7. "How much am I spending on food?"
    if (q.contains('food') || q.contains('dining') || q.contains('swiggy')) {
      final foodTx = transactions.where((t) => !t.isIncome && t.category.toLowerCase() == 'food');
      final total = foodTx.fold<double>(0, (sum, t) => sum + t.amount);
      return 'You have spent ₹${total.toStringAsFixed(0)} on Food across ${foodTx.length} transactions.\n${monthlyExpenses > 0 ? "This represents ${((total / monthlyExpenses) * 100).toStringAsFixed(1)}% of your expenses." : ""}';
    }

    // 8. "How much can I save if I reduce shopping by 20%?"
    if (q.contains('reduce shopping') || q.contains('shopping')) {
      final shopTx = transactions.where((t) => !t.isIncome && t.category.toLowerCase() == 'shopping');
      final total = shopTx.fold<double>(0, (sum, t) => sum + t.amount);
      final saving = total * 0.20;
      return 'Current shopping spending: ₹${total.toStringAsFixed(0)}.\nA 20% reduction saves ₹${saving.toStringAsFixed(0)} per month (₹${(saving * 12).toStringAsFixed(0)} annually), directly boosting your investment capacity.';
    }

    // Fallback general overview
    return 'FinPilot Financial Summary:\n• Balance: ₹${currentBalance.toStringAsFixed(0)}\n• Monthly Income: ₹${monthlyIncome.toStringAsFixed(0)}\n• Monthly Expenses: ₹${monthlyExpenses.toStringAsFixed(0)}\n• Monthly Savings: ₹${monthlySavings.toStringAsFixed(0)}\n\nYou can ask about car affordability, emergency fund targets, spending leaks, tax tips, or specific budget adjustments.';
  }
}
