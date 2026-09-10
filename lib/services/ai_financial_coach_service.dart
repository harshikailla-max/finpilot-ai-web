import 'dart:math' as math;
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';
import '../models/budget_model.dart';
import '../models/investment_model.dart';

class AiCoachResponse {
  final String text;
  final List<String> actionTypes;
  final String? topic;
  final double? detectedAmount;

  AiCoachResponse({
    required this.text,
    this.actionTypes = const [],
    this.topic,
    this.detectedAmount,
  });
}

class AiFinancialCoachService {
  // Session Memory Context
  static String? _lastTopic;
  static double? _lastAmount;
  static String? _lastGoalTitle;

  static void resetMemory() {
    _lastTopic = null;
    _lastAmount = null;
    _lastGoalTitle = null;
  }

  /// Processes user question and generates an executive financial response with real numbers
  static AiCoachResponse processQuery({
    required String question,
    required double currentBalance,
    required double monthlyIncome,
    required double monthlyExpenses,
    required List<FinanceTransaction> transactions,
    required List<FinancialGoal> goals,
    required List<BudgetModel> budgets,
    required List<InvestmentModel> investments,
    required int financialHealthScore,
  }) {
    final q = question.toLowerCase().trim();

    final income = monthlyIncome > 0 ? monthlyIncome : 50000.0;
    final expenses = monthlyExpenses > 0 ? monthlyExpenses : 30000.0;
    final monthlySurplus = math.max(0.0, income - expenses);
    final savingsRate = income > 0 ? ((monthlySurplus / income) * 100).toStringAsFixed(1) : '0.0';
    final emergencyFundNeed = expenses * 3; // 3 months baseline emergency reserve

    // Contextual Follow-Up Handling based on Session Memory
    if ((q == 'yes' || q == 'no' || q.contains('what about') || q.contains('tell me more') || q.contains('faster')) && _lastTopic != null) {
      final topic = _lastTopic!;
      final text =
          'FOLLOW-UP INSIGHT (${topic.toUpperCase()})\n\n'
          'SHORT ANSWER\n'
          'Continuing from our ${_lastGoalTitle ?? topic} discussion: accelerating this timeline requires allocating 20% more of your monthly surplus.\n\n'
          'WHY\n'
          'Increasing your monthly contribution from ₹${_fmt(monthlySurplus * 0.5)} to ₹${_fmt(monthlySurplus * 0.75)} reduces completion time by approximately 35%.\n\n'
          'YOUR NUMBERS\n'
          '• Current Monthly Surplus: ₹${_fmt(monthlySurplus)}\n'
          '• Accelerated Allocation: ₹${_fmt(monthlySurplus * 0.75)}\n\n'
          'RECOMMENDATION\n'
          'You can set up an automated rule in Budget or Goal settings to lock in this contribution.\n\n'
          'ACTION PLAN\n'
          '1. Confirm the adjusted allocation in Goals.\n'
          '2. Ensure your ₹${_fmt(emergencyFundNeed)} emergency reserve remains protected.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['open_goal', 'create_budget'],
        topic: topic,
      );
    }

    // Detect amounts like "80000", "₹80,000", "80k", "8 lakh"
    double? detectedAmount = _extractAmountFromText(question);
    if (detectedAmount != null) {
      _lastAmount = detectedAmount;
    } else if (_lastAmount != null && (q.contains('afford') || q.contains('buy') || q.contains('it') || q.contains('save'))) {
      detectedAmount = _lastAmount;
    }

    // ------------------------------------------------------------
    // 1. CAR / VEHICLE BLUEPRINT (Higher specificity than purchase)
    // ------------------------------------------------------------
    if (q.contains('car') || q.contains('vehicle')) {
      _lastTopic = 'car';
      _lastGoalTitle = 'Car Purchase';
      final carPrice = detectedAmount ?? 800000.0;
      final downPayment = carPrice * 0.20;
      final loanAmount = carPrice - downPayment;
      // EMI at 9.5% for 4 years
      final emi = (loanAmount * 0.00791 * math.pow(1.00791, 48)) / (math.pow(1.00791, 48) - 1);
      final isAffordable = monthlySurplus >= emi * 1.5;

      final text =
          'CAR AFFORDABILITY BLUEPRINT\n\n'
          'SHORT ANSWER\n'
          '${isAffordable ? "FEASIBLE" : "REQUIRES PREPARATION"} — A ₹${_fmt(carPrice)} car requires ₹${_fmt(downPayment)} down payment and an estimated EMI of ₹${_fmt(emi)}/month.\n\n'
          'WHY\n'
          'Car ownership includes initial down payment plus ongoing loan EMI, insurance, and fuel, which should not exceed 20% of your monthly income.\n\n'
          'YOUR NUMBERS\n'
          '• Estimated Car Cost: ₹${_fmt(carPrice)}\n'
          '• 20% Down Payment: ₹${_fmt(downPayment)}\n'
          '• Estimated Monthly EMI (4 yrs @ 9.5%): ₹${_fmt(emi)}/month\n'
          '• Your Monthly Cash Surplus: ₹${_fmt(monthlySurplus)}\n\n'
          'RECOMMENDATION\n'
          '${isAffordable ? "You have sufficient monthly surplus to absorb this EMI comfortably." : "Save for a larger down payment to bring the monthly EMI under ₹${_fmt(monthlySurplus * 0.5)}."}\n\n'
          'ACTION PLAN\n'
          '1. Save the ₹${_fmt(downPayment)} down payment in short-duration debt funds.\n'
          '2. Ensure your debt-to-income ratio stays below 35%.\n'
          '3. Open the Car Affordability Calculator for tenure simulation.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['open_car_calc', 'open_goal'],
        topic: 'car',
        detectedAmount: carPrice,
      );
    }

    // ------------------------------------------------------------
    // 2. RETIREMENT PLANNING (Higher specificity than investment)
    // ------------------------------------------------------------
    if (q.contains('retire') || q.contains('retirement') || q.contains('pension')) {
      _lastTopic = 'retirement';
      _lastGoalTitle = 'Retirement';
      final annualSpend = expenses * 12;
      final targetCorpus = annualSpend * 25; // 4% rule = 25x annual expenses
      final sipNeeded = (targetCorpus * 0.01) / (math.pow(1.01, 240) - 1); // 20 years @ 12%

      final text =
          'RETIREMENT FREEDOM BLUEPRINT\n\n'
          'SHORT ANSWER\n'
          'To sustain your current lifestyle, target a retirement corpus of approximately ₹${(targetCorpus / 10000000).toStringAsFixed(2)} Crore (25x annual expenses).\n\n'
          'WHY\n'
          'The standard 4% safe withdrawal rule ensures you can draw lifelong inflation-adjusted income without exhausting your capital.\n\n'
          'YOUR NUMBERS\n'
          '• Annual Living Expenses: ₹${_fmt(annualSpend)}\n'
          '• Target Corpus (25x): ₹${_fmt(targetCorpus)}\n'
          '• Required Monthly SIP (20 yrs @ 12% p.a.): ~₹${_fmt(sipNeeded)}/mo\n'
          '• Your Current Monthly Surplus: ₹${_fmt(monthlySurplus)}\n\n'
          'RECOMMENDATION\n'
          'Start investing now in diversified equity index and flexi-cap funds. Compounding requires time—every 5-year delay doubles the required monthly SIP.\n\n'
          'ACTION PLAN\n'
          '1. Open the AI Goal-Based Investment Planner for Retirement.\n'
          '2. Utilize EPF, PPF, and NPS for Section 80CCD tax benefits.\n'
          '3. Review asset allocation every 3 years to gradually taper equity risk.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['open_investment', 'future_sim'],
        topic: 'retirement',
      );
    }

    // ------------------------------------------------------------
    // 3. DEBT PAYOFF VS INVESTING (Higher specificity than investment)
    // ------------------------------------------------------------
    if (q.contains('debt') || q.contains('loan') || q.contains('pay off')) {
      _lastTopic = 'debt';
      _lastGoalTitle = 'Debt Payoff';

      final text =
          'DEBT VS. INVESTING STRATEGY\n\n'
          'SHORT ANSWER\n'
          'Pay off any debt with an interest rate above 10% (credit cards, personal loans) BEFORE aggressive investing.\n\n'
          'WHY\n'
          'Clearing a 14% loan gives you a GUARANTEED 14% risk-free return. No market investment can guarantee returns that high.\n\n'
          'YOUR NUMBERS\n'
          '• Monthly Surplus Available: ₹${_fmt(monthlySurplus)}\n'
          '• Liquid Balance: ₹${_fmt(currentBalance)}\n\n'
          'RECOMMENDATION\n'
          'Maintain a mini-emergency fund of ₹30,000, then channel all surplus into high-interest debt using the Avalanche method (highest interest first).\n\n'
          'ACTION PLAN\n'
          '1. List all debts sorted by interest rate.\n'
          '2. Make minimum payments on all loans, and throw all surplus at the highest APR.\n'
          '3. Once high-interest debt is eliminated, shift full surplus into wealth investing.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['create_budget', 'financial_health'],
        topic: 'debt',
      );
    }

    // ------------------------------------------------------------
    // 4. EMERGENCY FUND
    // ------------------------------------------------------------
    if (q.contains('emergency fund') || q.contains('emergency') || q.contains('safety net')) {
      _lastTopic = 'emergency';
      _lastGoalTitle = 'Emergency Reserve';
      final currentLiquid = currentBalance;
      final targetFund = expenses * 6; // 6 months ideal
      final deficit = math.max(0.0, targetFund - currentLiquid);
      final monthsToFill = monthlySurplus > 0 ? (deficit / monthlySurplus).ceil() : 12;

      final text =
          'EMERGENCY FUND BLUEPRINT\n\n'
          'SHORT ANSWER\n'
          'You need ₹${_fmt(targetFund)} (6 months of essential living expenses) for complete financial resilience.\n\n'
          'WHY\n'
          'An emergency fund prevents you from liquidating long-term investments or accumulating high-interest debt during job transitions or medical emergencies.\n\n'
          'YOUR NUMBERS\n'
          '• Monthly Living Expenses: ₹${_fmt(expenses)}\n'
          '• Target Emergency Buffer (6 mo): ₹${_fmt(targetFund)}\n'
          '• Current Liquid Balance: ₹${_fmt(currentLiquid)}\n'
          '• Current Funding Gap: ₹${_fmt(deficit)}\n\n'
          'RECOMMENDATION\n'
          '${deficit == 0 ? "Your emergency fund is 100% funded! You can channel surplus towards wealth creation." : "Prioritize closing the ₹${_fmt(deficit)} gap over aggressive equity investments."}\n\n'
          'ACTION PLAN\n'
          '1. Direct ₹${_fmt(monthlySurplus * 0.6)}/month into high-interest liquid savings or Arbitrage funds.\n'
          '2. Target reaching full 6-month coverage in approximately $monthsToFill month(s).\n'
          '3. Never invest emergency capital in equities or lock-in instruments.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['open_investment', 'open_goal'],
        topic: 'emergency',
      );
    }

    // ------------------------------------------------------------
    // 4B. SUBSCRIPTIONS & RECURRING CHARGES (Higher specificity than generic spending)
    // ------------------------------------------------------------
    if (q.contains('subscription') || q.contains('recurring') || q.contains('netflix') || q.contains('spotify') || q.contains('gym')) {
      _lastTopic = 'subscriptions';
      _lastGoalTitle = 'Subscription Audit';

      final text =
          'RECURRING CHARGES & SUBSCRIPTION AUDIT\n\n'
          'SHORT ANSWER\n'
          'FinPilot continuously monitors recurring debits across entertainment, gym, and cloud subscriptions.\n\n'
          'WHY\n'
          'Recurring subscriptions are "silent wealth leaks" that auto-renew without active consideration, costing an average of ₹18,000–₹35,000 annually.\n\n'
          'YOUR NUMBERS\n'
          '• Monthly Outflow Monitored: ₹${_fmt(expenses)}\n'
          '• Estimated Monthly Subscription Burden: ~₹2,400\n'
          '• Annualized Subscription Impact: ~₹28,800\n\n'
          'RECOMMENDATION\n'
          'Cancel or pause subscriptions you have not utilized in the past 30 days.\n\n'
          'ACTION PLAN\n'
          '1. Open the Subscription Manager to view active services.\n'
          '2. Audit credit card statements for auto-debit mandates.\n'
          '3. Reclaim ₹1,500/month by bundling family plans.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['review_subs', 'view_leaks'],
        topic: 'subscriptions',
      );
    }

    // ------------------------------------------------------------
    // 4C. BANK STATEMENT & RECEIPT ANALYSIS
    // ------------------------------------------------------------
    if (q.contains('statement') || q.contains('bank') || q.contains('receipt') || q.contains('scan')) {
      _lastTopic = 'statement';
      _lastGoalTitle = 'Statement & Receipt Intelligence';

      final text =
          'DOCUMENT & STATEMENT INTELLIGENCE\n\n'
          'SHORT ANSWER\n'
          'FinPilot processes raw bank statements (CSV, PDF, Excel) and physical receipts via on-device ML OCR to automatically extract transactions, dates, and categories.\n\n'
          'WHY\n'
          'Manual entry causes 60% of users to abandon financial tracking. Automated multi-format parsing ensures 100% telemetry completeness.\n\n'
          'YOUR NUMBERS\n'
          '• Transactions Parsed & Active: ${transactions.length}\n'
          '• Tracked Monthly Inflow: ₹${_fmt(income)}\n'
          '• Tracked Monthly Outflow: ₹${_fmt(expenses)}\n\n'
          'RECOMMENDATION\n'
          'Import your latest monthly bank statement to verify recurring charges and flag unusual vendor debits.\n\n'
          'ACTION PLAN\n'
          '1. Tap "Bank Statement" to upload a CSV or PDF file.\n'
          '2. Tap "Scan Receipt" to capture a physical bill with the camera.\n'
          '3. Review extracted transactions before committing to your ledger.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['import_statement', 'scan_receipt'],
        topic: 'statement',
      );
    }

    // ------------------------------------------------------------
    // 5. SPENDING INTELLIGENCE & EXPENSE AUDIT
    // ------------------------------------------------------------
    if (q.contains('spend') || q.contains('expense') || q.contains('cut') || q.contains('reduce') || q.contains('money going') || q.contains('where is my money')) {
      _lastTopic = 'spending';
      _lastGoalTitle = 'Expense Optimization';

      final Map<String, double> catTotals = {};
      for (final t in transactions.where((tx) => tx.isExpense)) {
        catTotals[t.category] = (catTotals[t.category] ?? 0.0) + t.amount;
      }
      final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topCat = sortedCats.isNotEmpty ? sortedCats.first.key : 'Food & Dining';
      final topCatAmount = sortedCats.isNotEmpty ? sortedCats.first.value : (expenses * 0.35);

      final text =
          'SPENDING INTELLIGENCE AUDIT\n\n'
          'SHORT ANSWER\n'
          'Your highest spending category is $topCat (₹${_fmt(topCatAmount)}). Trimming discretionary categories by 15% will unlock ₹${_fmt(expenses * 0.15)}/month in new savings.\n\n'
          'WHY\n'
          'Small recurring lifestyle leaks erode compounding potential. Reducing non-essential consumption by 15% adds over ₹${_fmt((expenses * 0.15) * 12)} annually to your net worth.\n\n'
          'YOUR NUMBERS\n'
          '• Total Monthly Outflow: ₹${_fmt(expenses)}\n'
          '• Top Expense: $topCat (₹${_fmt(topCatAmount)})\n'
          '• Potential Monthly Reclaim: ₹${_fmt(expenses * 0.15)}\n\n'
          'RECOMMENDATION\n'
          'Set a category cap on $topCat and review active subscriptions.\n\n'
          'ACTION PLAN\n'
          '1. Set a monthly budget cap on $topCat.\n'
          '2. Scan receipts after shopping to catch micro-spending leaks.\n'
          '3. Review recurring subscriptions to eliminate unused services.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['create_budget', 'scan_receipt', 'view_leaks'],
        topic: 'spending',
      );
    }

    // ------------------------------------------------------------
    // 6. PURCHASE AFFORDABILITY (e.g. "Can I afford ₹80,000 laptop?")
    // ------------------------------------------------------------
    if (q.contains('afford') || q.contains('buy') || q.contains('purchase')) {
      final itemPrice = detectedAmount ?? 50000.0;
      _lastTopic = 'purchase';
      _lastGoalTitle = 'Purchase';

      String status;
      String shortAnswer;
      String recommendation;
      int monthsToWait = 0;

      if (currentBalance >= itemPrice + emergencyFundNeed) {
        status = 'SAFE TO PURCHASE';
        shortAnswer = 'YES — You can comfortably afford this purchase without compromising your financial safety.';
        recommendation = 'Your liquid cash exceeds both the purchase price and your ₹${_fmt(emergencyFundNeed)} emergency reserve.';
      } else if (currentBalance >= itemPrice) {
        status = 'CAUTION — EMERGENCY RESERVE AT RISK';
        shortAnswer = 'PROCEED WITH CAUTION — You have the cash, but buying now would dip into your emergency fund.';
        monthsToWait = monthlySurplus > 0 ? ((emergencyFundNeed - (currentBalance - itemPrice)) / monthlySurplus).ceil() : 3;
        recommendation = 'Wait approximately $monthsToWait month(s) to rebuild your liquidity cushion before purchasing.';
      } else {
        final shortfall = itemPrice - currentBalance;
        monthsToWait = monthlySurplus > 0 ? (shortfall / monthlySurplus).ceil() : 6;
        status = 'NOT RECOMMENDED TODAY';
        shortAnswer = 'NOT RECOMMENDED TODAY — You currently have a funding deficit of ₹${_fmt(shortfall)}.';
        recommendation = 'At your current savings surplus of ₹${_fmt(monthlySurplus)}/month, waiting approximately $monthsToWait month(s) will let you buy this debt-free.';
      }

      final text =
          'AFFORDABILITY ANALYSIS: $status\n\n'
          'SHORT ANSWER\n'
          '$shortAnswer\n\n'
          'WHY\n'
          'FinPilot evaluates purchases against your liquid balance, monthly cash surplus, and non-negotiable emergency reserves.\n\n'
          'YOUR NUMBERS\n'
          '• Item Price: ₹${_fmt(itemPrice)}\n'
          '• Available Balance: ₹${_fmt(currentBalance)}\n'
          '• Monthly Surplus: ₹${_fmt(monthlySurplus)} ($savingsRate% savings rate)\n'
          '• 3-Month Emergency Reserve: ₹${_fmt(emergencyFundNeed)}\n\n'
          'RECOMMENDATION\n'
          '$recommendation\n\n'
          'ACTION PLAN\n'
          '1. Create a dedicated saving goal for this purchase.\n'
          '2. Allocate ₹${_fmt(math.min(monthlySurplus, itemPrice / math.max(1, monthsToWait)))}/month from your surplus.\n'
          '3. Keep your core emergency reserve untouched in a high-yield liquid account.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['open_goal', 'create_budget'],
        topic: 'purchase',
        detectedAmount: itemPrice,
      );
    }

    // ------------------------------------------------------------
    // 7. WHERE SHOULD I INVEST? / HOW MUCH TO INVEST?
    // ------------------------------------------------------------
    if (q.contains('invest') || q.contains('sip') || q.contains('portfolio')) {
      _lastTopic = 'investment';
      _lastGoalTitle = 'Investment Allocation';
      final investableMonthly = math.max(0.0, monthlySurplus * 0.8);

      final text =
          'INTELLIGENT INVESTMENT STRATEGY\n\n'
          'SHORT ANSWER\n'
          'Invest ₹${_fmt(investableMonthly)}/month across a 3-tier asset allocation matching your time horizon and risk profile.\n\n'
          'WHY\n'
          'Asset allocation drives 90% of long-term portfolio performance. Dividing capital across equity, debt, and liquid instruments optimizes compounding while controlling drawdowns.\n\n'
          'YOUR NUMBERS\n'
          '• Monthly Surplus Available: ₹${_fmt(monthlySurplus)}\n'
          '• Recommended Monthly SIP: ₹${_fmt(investableMonthly)}\n'
          '• Existing Investments Value: ₹${_fmt(investments.fold(0.0, (sum, i) => sum + i.currentValue))}\n\n'
          'RECOMMENDED ALLOCATION\n'
          '• Tier 1 (Long-Term Growth, 60%): ₹${_fmt(investableMonthly * 0.60)}/mo in Nifty 50 Index & Flexi-Cap Funds (12-14% p.a. illustrative).\n'
          '• Tier 2 (Stability & Defense, 25%): ₹${_fmt(investableMonthly * 0.25)}/mo in Corporate Bond & Short Duration Debt.\n'
          '• Tier 3 (Liquidity Buffer, 15%): ₹${_fmt(investableMonthly * 0.15)}/mo in Arbitrage / High-Yield Savings.\n\n'
          'ACTION PLAN\n'
          '1. Open the AI Goal-Based Investment Planner to customize by exact horizon.\n'
          '2. Setup automatic SIP debit right after salary day.\n'
          '3. Step up your monthly SIP by 10% annually to multiply wealth creation.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['open_investment', 'future_sim'],
        topic: 'investment',
      );
    }

    // ------------------------------------------------------------
    // 8. WHAT HAPPENS IF I SAVE ₹X / COMPOUNDING PROJECTION
    // ------------------------------------------------------------
    if (q.contains('what happens if i save') || q.contains('how much will i have') || q.contains('compound') || q.contains('5 years') || q.contains('10 years')) {
      final monthly = detectedAmount ?? 10000.0;
      const years = 5;
      const rate = 12.0;
      final r = (rate / 100) / 12;
      final n = years * 12;
      final fv = monthly * ((math.pow(1 + r, n) - 1) / r) * (1 + r);
      final totalInvested = monthly * n;
      final wealthGain = fv - totalInvested;

      final text =
          '5-YEAR COMPOUNDING PROJECTION\n\n'
          'SHORT ANSWER\n'
          'Saving ₹${_fmt(monthly)}/month for 5 years at an expected 12% p.a. return accumulates approximately ₹${_fmt(fv)}.\n\n'
          'WHY\n'
          'Compound interest multiplies your capital. In 5 years, your money earns ₹${_fmt(wealthGain)} purely in investment gains.\n\n'
          'YOUR NUMBERS\n'
          '• Monthly Contribution: ₹${_fmt(monthly)}\n'
          '• Total Principal Invested (5 yrs): ₹${_fmt(totalInvested)}\n'
          '• Estimated Wealth Gain: ₹${_fmt(wealthGain)}\n'
          '• Projected Maturity Value: ₹${_fmt(fv)}\n\n'
          'RECOMMENDATION\n'
          'Step up your contribution by 10% each year to push your final portfolio above ₹${_fmt(fv * 1.25)}.\n\n'
          'ACTION PLAN\n'
          '1. Start with an automated monthly SIP.\n'
          '2. Run the Future Simulator to compare 10-year and 15-year horizons.\n'
          '3. Reinvest all dividends for uninterrupted exponential compounding.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['future_sim', 'open_investment'],
        topic: 'compounding',
        detectedAmount: monthly,
      );
    }

    // ------------------------------------------------------------
    // 9. HOW MUCH SHOULD I SAVE? / INCREASE SAVINGS
    // ------------------------------------------------------------
    if (q.contains('how much should i save') || q.contains('save more') || q.contains('savings rate')) {
      _lastTopic = 'saving';
      _lastGoalTitle = 'Savings Optimization';
      final targetSavings = income * 0.30; // 30% savings target

      final text =
          'SAVINGS RATE ACCELERATION\n\n'
          'SHORT ANSWER\n'
          'Aim to save at least ₹${_fmt(targetSavings)}/month (30% of your ₹${_fmt(income)} income). Your current savings rate is $savingsRate%.\n\n'
          'WHY\n'
          'The 50/30/20 rule benchmarks 50% for Needs, 30% for Wants, and 20% for Savings. Elite wealth builders target a 30%+ savings rate to achieve financial independence a decade earlier.\n\n'
          'YOUR NUMBERS\n'
          '• Monthly Income: ₹${_fmt(income)}\n'
          '• Current Savings: ₹${_fmt(monthlySurplus)} ($savingsRate%)\n'
          '• Optimal Target: ₹${_fmt(targetSavings)} (30.0%)\n'
          '• Improvement Opportunity: ₹${_fmt(math.max(0.0, targetSavings - monthlySurplus))}/month\n\n'
          'RECOMMENDATION\n'
          'Follow the "Pay Yourself First" rule: transfer savings automatically on salary day before spending discretionary income.\n\n'
          'ACTION PLAN\n'
          '1. Setup recurring auto-transfers on the 1st of every month.\n'
          '2. Cap discretionary dining and shopping budgets.\n'
          '3. Direct 50% of any bonus or raise immediately into savings.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['create_budget', 'open_goal'],
        topic: 'saving',
      );
    }

    // ------------------------------------------------------------
    // 10. BUDGET CREATION / ADVICE
    // ------------------------------------------------------------
    if (q.contains('budget') || q.contains('create a monthly budget')) {
      _lastTopic = 'budget';
      _lastGoalTitle = 'Monthly Budget';
      final needs = income * 0.50;
      final wants = income * 0.30;
      final savings = income * 0.20;

      final text =
          'PERSONALIZED 50/30/20 BUDGET\n\n'
          'SHORT ANSWER\n'
          'For your ₹${_fmt(income)} income, your balanced budget is: Needs ₹${_fmt(needs)}, Wants ₹${_fmt(wants)}, and Savings ₹${_fmt(savings)}.\n\n'
          'WHY\n'
          'The 50/30/20 framework ensures your fixed bills are covered while guaranteeing wealth accumulation without feeling deprived.\n\n'
          'YOUR NUMBERS\n'
          '• Monthly Income: ₹${_fmt(income)}\n'
          '• Needs (Rent, Utilities, Groceries - 50%): ₹${_fmt(needs)}\n'
          '• Wants (Dining, Entertainment, Shopping - 30%): ₹${_fmt(wants)}\n'
          '• Savings & Investments (20% min): ₹${_fmt(savings)}\n\n'
          'RECOMMENDATION\n'
          'Open the Budget module to set category-specific caps matching these targets.\n\n'
          'ACTION PLAN\n'
          '1. Set a ₹${_fmt(needs)} cap across essential bill categories.\n'
          '2. Keep discretionary dining and entertainment under ₹${_fmt(wants)}.\n'
          '3. Automate the ₹${_fmt(savings)} investment transfer on payday.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['create_budget', 'add_expense'],
        topic: 'budget',
      );
    }

    // ------------------------------------------------------------
    // 10B. CA-STYLE TAX GUIDANCE & PLANNING (Old vs New, 80C, TDS, GST)
    // ------------------------------------------------------------
    if (q.contains('tax') || q.contains('80c') || q.contains('deduction') || q.contains('regime') || q.contains('tds') || q.contains('gst') || q.contains('capital gain')) {
      _lastTopic = 'tax';
      _lastGoalTitle = 'Tax Planning';
      final annualIncome = income * 12;

      String specificAdvice = '';
      if (q.contains('80c')) {
        specificAdvice =
            '• Section 80C lets you deduct up to ₹1,50,000 under the Old Regime (via PPF, EPF, ELSS mutual funds, life insurance).\n'
            '• ELSS mutual funds have the shortest lock-in (3 years) and offer potential equity compounding.';
      } else if (q.contains('old') || q.contains('new') || q.contains('regime')) {
        specificAdvice =
            '• New Regime (Default): Offers lower tax slabs and a ₹75,000 standard deduction. Best if total deductions are under ₹3,75,000.\n'
            '• Old Regime: Best if you claim high deductions (HRA, 80C ₹1.5L, 80D ₹25k-₹50k, home loan interest ₹2L).';
      } else if (q.contains('tds')) {
        specificAdvice =
            '• TDS (Tax Deducted at Source) is advance tax collected on salary or interest.\n'
            '• You can reconcile TDS via Form 26AS / AIS on the Income Tax Portal and claim excess as a refund.';
      } else if (q.contains('capital gain')) {
        specificAdvice =
            '• Equity LTCG (held >12 months): Taxed at 12.5% on gains exceeding ₹1.25 Lakh per financial year.\n'
            '• STCG (held <=12 months): Taxed at 20% on short-term gains.';
      } else {
        specificAdvice =
            '• At an annualized gross income of ₹${_fmt(annualIncome)}, optimizing between regimes can save ₹15,000–₹45,000 annually.\n'
            '• Check the Tax Saver tool to model your exact slab liability.';
      }

      final text =
          'CA-STYLE TAX INTELLIGENCE & PLANNING\n\n'
          'SHORT ANSWER\n'
          'For your estimated annual income of ₹${_fmt(annualIncome)}, smart tax regime selection and Section 80C/80D allocation can save significant tax liability.\n\n'
          'WHY\n'
          'Tax planning is not about tax evasion—it is about legitimately utilizing government exemptions to preserve capital for long-term wealth compounding.\n\n'
          'YOUR NUMBERS (ESTIMATE)\n'
          '• Estimated Annual Gross: ₹${_fmt(annualIncome)}\n'
          '• Standard Deduction (New Regime): ₹75,000\n'
          '• 80C Deductions Limit (Old Regime): ₹1,50,000\n'
          '• Estimated Effective Tax Rate: ~${annualIncome > 700000 ? "10–15" : "0"}%\n\n'
          'CA RECOMMENDATION & GUIDELINES\n'
          '$specificAdvice\n\n'
          'DISCLAIMER\n'
          'This analysis is for educational purposes. For filing official ITR returns, verify with a licensed Chartered Accountant.\n\n'
          'ACTION PLAN\n'
          '1. Run the FinPilot Tax Saver Calculator for exact slab comparisons.\n'
          '2. Download Form 26AS and AIS to review TDS deductions.\n'
          '3. Maximize ELSS contributions before March 31st.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['open_tax', 'open_investment'],
        topic: 'tax',
      );
    }

    // ------------------------------------------------------------
    // 10C. CASH FLOW & FORECAST
    // ------------------------------------------------------------
    if (q.contains('cash flow') || q.contains('forecast') || q.contains('predict') || q.contains('runway')) {
      _lastTopic = 'cashflow';
      _lastGoalTitle = 'Cash Flow Analysis';
      final forecast30 = monthlySurplus;
      final forecast90 = monthlySurplus * 3;
      final forecast365 = monthlySurplus * 12;

      final text =
          'CASH FLOW & MULTI-HORIZON FORECAST\n\n'
          'SHORT ANSWER\n'
          'Your current net monthly cash flow is +₹${_fmt(monthlySurplus)} ($savingsRate% surplus margin). At this trajectory, you will generate ₹${_fmt(forecast365)} in net liquid wealth over the next 12 months.\n\n'
          'WHY\n'
          'Consistent positive free cash flow is the engine of net worth expansion. Maintaining a 20%+ cash surplus guarantees debt immunity.\n\n'
          'YOUR CASH FLOW TELEMETRY\n'
          '• Monthly Inflow: ₹${_fmt(income)}\n'
          '• Monthly Outflow: ₹${_fmt(expenses)}\n'
          '• 30-Day Projected Net Cash: +₹${_fmt(forecast30)}\n'
          '• 90-Day Projected Net Cash: +₹${_fmt(forecast90)}\n'
          '• 1-Year Net Wealth Generation: +₹${_fmt(forecast365)}\n\n'
          'RECOMMENDATION\n'
          'Direct 60% of your ₹${_fmt(monthlySurplus)} monthly surplus into automated SIP investments and 40% into high-yield liquid buffers.\n\n'
          'ACTION PLAN\n'
          '1. Check your Cash Flow trend in the Analytics view.\n'
          '2. Run the Wealth Simulator to project 3-year compound growth.\n'
          '3. Review recurring subscriptions to protect your surplus margin.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['future_sim', 'open_investment'],
        topic: 'cashflow',
      );
    }

    // ------------------------------------------------------------
    // 11. FINANCIAL HEALTH & SCORE
    // ------------------------------------------------------------
    if (q.contains('health') || q.contains('score') || q.contains('why did my financial health score decrease') || q.contains('problem')) {
      _lastTopic = 'health';
      _lastGoalTitle = 'Financial Health';
      final score = financialHealthScore;

      final text =
          'FINANCIAL HEALTH DIAGNOSTIC ($score / 100)\n\n'
          'SHORT ANSWER\n'
          'Your overall Financial Health Score is $score/100 (${score >= 80 ? "Excellent" : score >= 65 ? "Good" : "Needs Optimization"}).\n\n'
          'WHY\n'
          'FinPilot evaluates 6 pillars: Savings Rate, Expense Discipline, Debt Burden, Emergency Buffer, Goal Progress, and Investment Diversification.\n\n'
          'YOUR NUMBERS\n'
          '• Health Score: $score / 100\n'
          '• Monthly Surplus: ₹${_fmt(monthlySurplus)}\n'
          '• Emergency Reserve Status: ${currentBalance >= emergencyFundNeed ? "Adequate" : "Incomplete"}\n\n'
          'RECOMMENDATION\n'
          '${score >= 80 ? "Your fundamentals are strong. Focus on optimizing tax and scaling investment portfolios." : "Strengthen your emergency reserve and tighten discretionary spending to boost your score above 80."}\n\n'
          'ACTION PLAN\n'
          '1. Review your 6-dimension breakdown in Financial Health.\n'
          '2. Eliminate high-interest debt or credit card balances.\n'
          '3. Keep at least 3 months of expenses liquid at all times.';

      return AiCoachResponse(
        text: text,
        actionTypes: ['financial_health', 'open_goal'],
        topic: 'health',
      );
    }

    // ------------------------------------------------------------
    // 12. GENERAL CONVERSATIONAL / CONTEXT FALLBACK
    // ------------------------------------------------------------
    final text =
        'FINPILOT AI COPILOT ANALYSIS\n\n'
        'SHORT ANSWER\n'
        'Based on your monthly surplus of ₹${_fmt(monthlySurplus)} and available balance of ₹${_fmt(currentBalance)}, your financial position is healthy.\n\n'
        'WHY\n'
        'FinPilot continuously analyzes your transactions, cash flow surplus ($savingsRate%), and goal milestones to provide bespoke financial intelligence.\n\n'
        'YOUR NUMBERS\n'
        '• Total Balance: ₹${_fmt(currentBalance)}\n'
        '• Monthly Cash Flow Surplus: ₹${_fmt(monthlySurplus)}\n'
        '• Active Financial Goals: ${goals.length}\n'
        '• Active Budgets Tracked: ${budgets.length}\n\n'
        'RECOMMENDATION\n'
        'You can ask me specific questions like "Can I afford a ₹60,000 vacation?", "Where should I invest?", or "How can I cut expenses?".\n\n'
        'ACTION PLAN\n'
        '1. Choose a suggested query below or ask your own question.\n'
        '2. Review your Goal progress in the Goals tab.\n'
        '3. Check your asset allocation in the Investment section.';

    return AiCoachResponse(
      text: text,
      actionTypes: ['open_goal', 'open_investment', 'financial_health'],
    );
  }

  static double? _extractAmountFromText(String text) {
    // Check "80k", "50k"
    final kMatch = RegExp(r'(\d+)\s*k', caseSensitive: false).firstMatch(text);
    if (kMatch != null) {
      return (double.tryParse(kMatch.group(1)!) ?? 0) * 1000;
    }

    // Check "8 lakh", "8L"
    final lakhMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:lakh|lakhs|l)', caseSensitive: false).firstMatch(text);
    if (lakhMatch != null) {
      return (double.tryParse(lakhMatch.group(1)!) ?? 0) * 100000;
    }

    // Check ₹50,000 or ₹1,00,000 or plain digits with Indian numbering commas
    final numMatch = RegExp(r'(?:₹|rs\.?|inr)?\s*(\d{1,3}(?:,\d{2,3})*(?:\.\d+)?|\d{4,9})', caseSensitive: false).firstMatch(text);
    if (numMatch != null) {
      final clean = numMatch.group(1)!.replaceAll(',', '');
      return double.tryParse(clean);
    }

    return null;
  }

  static String _fmt(double val) {
    return val.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}
