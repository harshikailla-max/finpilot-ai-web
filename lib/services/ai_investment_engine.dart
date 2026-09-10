import 'dart:math' as math;
import '../models/ai_investment_goal_plan.dart';

class AiInvestmentEngine {
  // ============================================================
  // 1. FINANCIAL MATHEMATICS (PMT, FV, DEFICIT)
  // ============================================================

  /// Calculates required monthly SIP contribution to reach Target Amount from Current Savings.
  /// Uses the standard financial annuity PMT formula compounded monthly:
  /// Target = CurrentSavings * (1+r)^n + PMT * [ ((1+r)^n - 1) / r ] * (1+r)
  static double calculateRequiredMonthlyInvestment({
    required double targetAmount,
    required double currentSavings,
    required int monthsRemaining,
    required double annualRate,
  }) {
    if (monthsRemaining <= 0) {
      return math.max(0.0, targetAmount - currentSavings);
    }

    final r = (annualRate / 100.0) / 12.0;

    // Future value of current lump-sum savings
    final fvCurrent = currentSavings * math.pow(1.0 + r, monthsRemaining);
    final deficit = math.max(0.0, targetAmount - fvCurrent);

    if (deficit <= 0) return 0.0;

    if (r <= 0) {
      return deficit / monthsRemaining;
    }

    // PMT for annuity due (payments at start of month)
    final pmt = (deficit * r) / ((math.pow(1.0 + r, monthsRemaining) - 1.0) * (1.0 + r));
    return math.max(0.0, pmt);
  }

  /// Calculates projected future value of Current Savings + Monthly Contributions
  static double calculateFutureValue({
    required double currentSavings,
    required double monthlyContribution,
    required int monthsRemaining,
    required double annualRate,
  }) {
    if (monthsRemaining <= 0) {
      return currentSavings;
    }

    final r = (annualRate / 100.0) / 12.0;
    final fvCurrent = currentSavings * math.pow(1.0 + r, monthsRemaining);

    if (monthlyContribution <= 0) return fvCurrent;

    if (r <= 0) {
      return fvCurrent + (monthlyContribution * monthsRemaining);
    }

    final fvSip = monthlyContribution *
        ((math.pow(1.0 + r, monthsRemaining) - 1.0) / r) *
        (1.0 + r);

    return fvCurrent + fvSip;
  }

  /// Probability score (0 - 100%) that the goal will be reached based on capacity vs requirement
  static int calculateGoalProbability({
    required double monthlyCapacity,
    required double requiredMonthly,
  }) {
    if (requiredMonthly <= 0) return 99;
    if (monthlyCapacity <= 0) return 15;

    final ratio = monthlyCapacity / requiredMonthly;
    if (ratio >= 1.2) return 98;
    if (ratio >= 1.0) return 92;
    if (ratio >= 0.85) return 80;
    if (ratio >= 0.70) return 65;
    if (ratio >= 0.50) return 45;
    return (ratio * 60).clamp(10, 40).toInt();
  }

  // ============================================================
  // 2. RISK QUESTIONNAIRE & SCORING
  // ============================================================

  static List<RiskQuestion> getRiskQuestions() {
    return [
      RiskQuestion(
        id: 'q1',
        question: 'How would you react if your investment temporarily fell 15%?',
        options: [
          RiskOption(label: 'Panic and withdraw immediately to prevent further loss', points: 5),
          RiskOption(label: 'Feel uneasy but wait for the market to recover', points: 15),
          RiskOption(label: 'Stay calm and view it as a buying opportunity to invest more', points: 25),
        ],
      ),
      RiskQuestion(
        id: 'q2',
        question: 'How flexible is the target timeline for this goal?',
        options: [
          RiskOption(label: 'Strict deadline — I must have the money by the exact date', points: 5),
          RiskOption(label: 'Somewhat flexible — I can delay by 6 to 12 months if needed', points: 15),
          RiskOption(label: 'Completely flexible — long-term growth is my primary concern', points: 25),
        ],
      ),
      RiskQuestion(
        id: 'q3',
        question: 'How critical is this goal to your financial security?',
        options: [
          RiskOption(label: 'Essential & Non-negotiable (e.g. Emergency, Child Education)', points: 5),
          RiskOption(label: 'Important life milestone (e.g. Car, Home Down Payment)', points: 15),
          RiskOption(label: 'Discretionary wealth building or aspirational dream', points: 25),
        ],
      ),
      RiskQuestion(
        id: 'q4',
        question: 'Can you continue investing fixed monthly amounts during prolonged market drops?',
        options: [
          RiskOption(label: 'No, I would pause investments until things look positive', points: 5),
          RiskOption(label: 'Yes, I will maintain my regular monthly SIP consistently', points: 15),
          RiskOption(label: 'Yes, and I would deploy additional surplus funds', points: 25),
        ],
      ),
      RiskQuestion(
        id: 'q5',
        question: 'Which statement best describes your investment philosophy?',
        options: [
          RiskOption(label: 'Preserving capital with guaranteed, stable returns', points: 5),
          RiskOption(label: 'Balanced approach: beat inflation with controlled volatility', points: 15),
          RiskOption(label: 'Maximum compounding wealth, fully accepting market swings', points: 25),
        ],
      ),
    ];
  }

  static RiskProfileLevel evaluateRiskScore(int totalScore) {
    if (totalScore <= 35) return RiskProfileLevel.conservative;
    if (totalScore <= 65) return RiskProfileLevel.balanced;
    if (totalScore <= 85) return RiskProfileLevel.growth;
    return RiskProfileLevel.aggressive;
  }

  // ============================================================
  // 3. RULE-BASED DYNAMIC RECOMMENDATION ENGINE
  // ============================================================

  /// Generates the Top 3 Strategies, AI Analysis, and Full Plan based on Goal inputs
  static AiInvestmentPlan buildPlan({
    required InvestmentGoalType goalType,
    required String goalTitle,
    required double targetAmount,
    required DateTime targetDate,
    required double currentSavings,
    required double monthlyCapacity,
    required RiskProfileLevel riskProfile,
    int? manualRiskScore,
  }) {
    final now = DateTime.now();
    final monthsRemaining = math.max(1, ((targetDate.year - now.year) * 12) + targetDate.month - now.month);
    final yearsRemaining = monthsRemaining / 12.0;

    final riskScore = manualRiskScore ??
        (riskProfile == RiskProfileLevel.conservative
            ? 30
            : riskProfile == RiskProfileLevel.balanced
                ? 55
                : riskProfile == RiskProfileLevel.growth
                    ? 75
                    : 90);

    // Generate Strategies customized for this specific goal + horizon + risk
    final strategies = _generateStrategiesForGoal(
      goalType: goalType,
      yearsRemaining: yearsRemaining,
      monthsRemaining: monthsRemaining,
      riskProfile: riskProfile,
      targetAmount: targetAmount,
    );

    final primaryStrategy = strategies.first;

    // Calculate required monthly contribution based on the primary strategy's expected return
    final requiredMonthly = calculateRequiredMonthlyInvestment(
      targetAmount: targetAmount,
      currentSavings: currentSavings,
      monthsRemaining: monthsRemaining,
      annualRate: primaryStrategy.expectedReturnRate,
    );

    final deficit = math.max(0.0, targetAmount - currentSavings);
    final probability = calculateGoalProbability(
      monthlyCapacity: monthlyCapacity,
      requiredMonthly: requiredMonthly,
    );

    final isAchievable = probability >= 70;
    String feasibilityLabel = 'Achievable';
    if (probability < 45) {
      feasibilityLabel = 'Requires Higher Contribution';
    } else if (probability < 70) {
      feasibilityLabel = 'Requires Plan Adjustment';
    }

    final aiAnalysis = _generateAiGoalAnalysis(
      goalType: goalType,
      targetAmount: targetAmount,
      yearsRemaining: yearsRemaining,
      riskProfile: riskProfile,
      monthlyCapacity: monthlyCapacity,
      requiredMonthly: requiredMonthly,
      strategy: primaryStrategy,
    );

    final aiRecommendation = _generateAiRecommendationSummary(
      goalType: goalType,
      yearsRemaining: yearsRemaining,
      riskProfile: riskProfile,
      requiredMonthly: requiredMonthly,
      strategy: primaryStrategy,
      feasibilityLabel: feasibilityLabel,
    );

    return AiInvestmentPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      goalType: goalType,
      goalTitle: goalTitle.isNotEmpty ? goalTitle : goalType.displayName,
      targetAmount: targetAmount,
      targetDate: targetDate,
      currentSavings: currentSavings,
      monthlyCapacity: monthlyCapacity,
      riskProfile: riskProfile,
      riskScore: riskScore,
      selectedStrategy: primaryStrategy,
      allStrategies: strategies,
      requiredMonthlyContribution: requiredMonthly,
      remainingDeficit: deficit,
      monthsRemaining: monthsRemaining,
      isAchievable: isAchievable,
      feasibilityLabel: feasibilityLabel,
      aiAnalysisText: aiAnalysis,
      aiRecommendationSummary: aiRecommendation,
      createdAt: DateTime.now(),
    );
  }

  static List<InvestmentStrategy> _generateStrategiesForGoal({
    required InvestmentGoalType goalType,
    required double yearsRemaining,
    required int monthsRemaining,
    required RiskProfileLevel riskProfile,
    required double targetAmount,
  }) {
    // ------------------------------------------------------------
    // SPECIAL CASE 1: EMERGENCY FUND
    // ------------------------------------------------------------
    if (goalType == InvestmentGoalType.emergency) {
      return [
        InvestmentStrategy(
          id: 'emergency_liquid_shield',
          name: 'Liquid Shield Strategy',
          badgeText: '#1 RECOMMENDED',
          matchScore: 97,
          riskLevel: 'Low',
          suggestedHorizon: 'Immediate / Liquid',
          potentialGrowthRange: '6.5% - 7.5% p.a.',
          expectedReturnRate: 7.0,
          liquidity: 'Instant / T+1 day',
          equityPercentage: 0,
          debtPercentage: 40,
          liquidPercentage: 60,
          whyItFits: 'Prioritizes immediate access and absolute capital safety. Zero equity market downside risk.',
          whyItMayNotFit: 'Returns do not beat long-term inflation, but optimal for emergency buffers.',
          recommendedCategories: ['Instant-Redemption Liquid Mutual Funds', 'High-Yield Bank Savings / Sweep FDs', 'Ultra-Short Duration Debt'],
          sampleInstruments: ['Liquid Mutual Funds (T+1)', 'Auto-Sweep Fixed Deposits', 'Overnight Debt Funds'],
        ),
        InvestmentStrategy(
          id: 'emergency_arbitrage_plus',
          name: 'Arbitrage Cash Flow',
          badgeText: '#2 ALTERNATIVE',
          matchScore: 90,
          riskLevel: 'Low-Moderate',
          suggestedHorizon: '6 - 12 Months',
          potentialGrowthRange: '7.2% - 8.2% p.a.',
          expectedReturnRate: 7.5,
          liquidity: 'High (T+2 days)',
          equityPercentage: 0,
          debtPercentage: 30,
          liquidPercentage: 70,
          whyItFits: 'Tax-efficient returns utilizing arbitrage equity spreads with zero unhedged equity risk.',
          whyItMayNotFit: 'Takes 1–2 business days to withdraw compared to instant bank sweeps.',
          recommendedCategories: ['Arbitrage Mutual Funds', 'Money Market Funds', 'Short-Term Fixed Income'],
          sampleInstruments: ['Arbitrage Funds (Equity Taxation)', 'Money Market Liquid Funds'],
        ),
        InvestmentStrategy(
          id: 'emergency_safe_fd',
          name: 'Guaranteed Fixed Deposit Sweep',
          badgeText: '#3 DEFENSIVE',
          matchScore: 84,
          riskLevel: 'Ultra-Low',
          suggestedHorizon: 'Flexible',
          potentialGrowthRange: '6.8% - 7.4% p.a.',
          expectedReturnRate: 7.1,
          liquidity: 'Instant (Premature Penalty may apply)',
          equityPercentage: 0,
          debtPercentage: 80,
          liquidPercentage: 20,
          whyItFits: 'Guaranteed principal under DICGC insurance (up to ₹5L per bank). 100% predictable.',
          whyItMayNotFit: 'Interest is fully taxable at individual slab rate.',
          recommendedCategories: ['Scheduled Commercial Bank FDs', 'Flexi Recurring Deposits'],
          sampleInstruments: ['Bank Fixed Deposits', 'Flexi Auto-Sweep Accounts'],
        ),
      ];
    }

    // ------------------------------------------------------------
    // SPECIAL CASE 2: TAX SAVING
    // ------------------------------------------------------------
    if (goalType == InvestmentGoalType.taxSaving) {
      return [
        InvestmentStrategy(
          id: 'tax_elss_growth',
          name: 'ELSS Wealth Builder',
          badgeText: '#1 RECOMMENDED',
          matchScore: 95,
          riskLevel: 'Moderate-High',
          suggestedHorizon: '3+ Years',
          potentialGrowthRange: '12% - 15% p.a.',
          expectedReturnRate: 13.5,
          liquidity: 'Locked for 3 Years (Lowest 80C Lock-in)',
          equityPercentage: 70,
          debtPercentage: 20,
          liquidPercentage: 10,
          whyItFits: 'Shortest statutory lock-in among Section 80C options (3 years) combined with compounding equity upside.',
          whyItMayNotFit: 'Subject to equity volatility during the 3-year holding period.',
          recommendedCategories: ['ELSS Tax-Saver Equity Mutual Funds', 'PPF for Debt Stability', 'NPS Tier 1'],
          sampleInstruments: ['ELSS Tax Saver Funds', 'Public Provident Fund (PPF)', 'NPS Corporate Debt'],
        ),
        InvestmentStrategy(
          id: 'tax_balanced_80c',
          name: 'Balanced 80C Saver',
          badgeText: '#2 ALTERNATIVE',
          matchScore: 89,
          riskLevel: 'Moderate',
          suggestedHorizon: '3 - 5 Years',
          potentialGrowthRange: '9.5% - 11.5% p.a.',
          expectedReturnRate: 10.5,
          liquidity: 'Partial Lock-in',
          equityPercentage: 45,
          debtPercentage: 45,
          liquidPercentage: 10,
          whyItFits: 'Combines the safety of PPF / 5-Yr Tax FD with growth from ELSS mutual funds.',
          whyItMayNotFit: 'PPF component has a 15-year maturity commitment.',
          recommendedCategories: ['50% ELSS Tax Saver Funds', '50% PPF or 5-Year Tax Saver FDs'],
          sampleInstruments: ['ELSS Mutual Funds', 'PPF Accounts', 'Tax-Saving Fixed Deposits'],
        ),
        InvestmentStrategy(
          id: 'tax_safe_haven',
          name: 'Guaranteed 80C Security',
          badgeText: '#3 DEFENSIVE',
          matchScore: 82,
          riskLevel: 'Low',
          suggestedHorizon: '5+ Years',
          potentialGrowthRange: '7.1% - 7.5% p.a.',
          expectedReturnRate: 7.2,
          liquidity: 'Locked (5 - 15 Years)',
          equityPercentage: 0,
          debtPercentage: 90,
          liquidPercentage: 10,
          whyItFits: 'Sovereign-backed tax deduction with zero capital risk.',
          whyItMayNotFit: 'Rigid lock-in periods (5 years for FD, 15 years for PPF).',
          recommendedCategories: ['Public Provident Fund (PPF)', '5-Year Tax-Saver Bank Fixed Deposits', 'National Savings Certificate (NSC)'],
          sampleInstruments: ['PPF (Sovereign Guaranteed)', '5-Year Tax Saver FDs'],
        ),
      ];
    }

    // ------------------------------------------------------------
    // GENERAL GOALS: HORIZON-BASED INTELLIGENCE (0-2y, 2-5y, 5-10y, 10y+)
    // ------------------------------------------------------------

    // 1. VERY SHORT TERM (0 - 2 Years)
    if (yearsRemaining <= 2.0) {
      return [
        InvestmentStrategy(
          id: 'short_capital_shield',
          name: 'Capital Preservation Strategy',
          badgeText: '#1 RECOMMENDED',
          matchScore: 94,
          riskLevel: 'Low',
          suggestedHorizon: '$monthsRemaining Months',
          potentialGrowthRange: '6.8% - 7.6% p.a.',
          expectedReturnRate: 7.2,
          liquidity: 'High',
          equityPercentage: 10,
          debtPercentage: 65,
          liquidPercentage: 25,
          whyItFits: 'Near-term deadline demands zero equity drawdown risk so your target amount is safeguarded.',
          whyItMayNotFit: 'Modest returns compared to stock market rallies.',
          recommendedCategories: ['Short-Duration Debt Funds', 'Arbitrage Mutual Funds', 'High-Yield Fixed Deposits'],
          sampleInstruments: ['Low Duration Debt Funds', 'Arbitrage Funds', 'Corporate Bond Funds (AAA)'],
        ),
        InvestmentStrategy(
          id: 'short_conservative_hybrid',
          name: 'Conservative Hybrid Yield',
          badgeText: '#2 ALTERNATIVE',
          matchScore: 86,
          riskLevel: 'Low-Moderate',
          suggestedHorizon: '1.5 - 2 Years',
          potentialGrowthRange: '8.0% - 9.5% p.a.',
          expectedReturnRate: 8.5,
          liquidity: 'Moderate-High',
          equityPercentage: 25,
          debtPercentage: 60,
          liquidPercentage: 15,
          whyItFits: 'Allows a modest 25% large-cap equity tilt to enhance returns without risking core capital.',
          whyItMayNotFit: 'Small downside risk if markets experience short-term correction.',
          recommendedCategories: ['Conservative Hybrid Funds', 'Equity Savings Mutual Funds'],
          sampleInstruments: ['Equity Savings Funds', 'Conservative Hybrid Portfolios'],
        ),
        InvestmentStrategy(
          id: 'short_liquid_secure',
          name: 'Ultra-Safe Liquid Buffer',
          badgeText: '#3 DEFENSIVE',
          matchScore: 81,
          riskLevel: 'Ultra-Low',
          suggestedHorizon: 'Up to 1 Year',
          potentialGrowthRange: '6.5% - 7.0% p.a.',
          expectedReturnRate: 6.8,
          liquidity: 'Instant / Very High',
          equityPercentage: 0,
          debtPercentage: 50,
          liquidPercentage: 50,
          whyItFits: 'Absolute safety and flexibility to withdraw funds at any moment without exit load.',
          whyItMayNotFit: 'Lower return rate requires a slightly higher monthly contribution.',
          recommendedCategories: ['Liquid Mutual Funds', 'Treasury Bills / Government Gilts', 'Bank Fixed Deposits'],
          sampleInstruments: ['Liquid Funds', 'Overnight Funds', 'T-Bills'],
        ),
      ];
    }

    // 2. SHORT-TO-MEDIUM TERM (2 - 5 Years, e.g. Car, Wedding, Home Down Payment)
    if (yearsRemaining <= 5.0) {
      if (riskProfile == RiskProfileLevel.conservative) {
        return [
          InvestmentStrategy(
            id: 'med_conservative_balanced',
            name: 'Debt & Equity Hybrid Shield',
            badgeText: '#1 RECOMMENDED',
            matchScore: 93,
            riskLevel: 'Low-Moderate',
            suggestedHorizon: '${yearsRemaining.toStringAsFixed(1)} Years',
            potentialGrowthRange: '8.5% - 10.5% p.a.',
            expectedReturnRate: 9.5,
            liquidity: 'Moderate-High',
            equityPercentage: 30,
            debtPercentage: 55,
            liquidPercentage: 15,
            whyItFits: 'Tailored for your Conservative preference while matching your ${yearsRemaining.toStringAsFixed(0)}-year milestone.',
            whyItMayNotFit: 'Equity portion may dip in negative market years.',
            recommendedCategories: ['Conservative Hybrid Funds', 'Short Duration Debt', 'Large Cap Index (15%)'],
            sampleInstruments: ['Multi-Asset Allocation Funds', 'Corporate Bond Funds', 'Nifty 50 Index'],
          ),
          InvestmentStrategy(
            id: 'med_balanced_growth',
            name: 'Balanced Advantage Allocation',
            badgeText: '#2 ALTERNATIVE',
            matchScore: 87,
            riskLevel: 'Moderate',
            suggestedHorizon: '3 - 5 Years',
            potentialGrowthRange: '10.5% - 12.5% p.a.',
            expectedReturnRate: 11.0,
            liquidity: 'High',
            equityPercentage: 45,
            debtPercentage: 45,
            liquidPercentage: 10,
            whyItFits: 'Dynamic asset allocation: automatically shifts between equity and debt based on market valuations.',
            whyItMayNotFit: 'Slightly higher volatility than pure debt portfolios.',
            recommendedCategories: ['Balanced Advantage Funds (BAF)', 'Dynamic Asset Allocation Funds'],
            sampleInstruments: ['Dynamic Asset Allocation Funds', 'Banking & PSU Debt Funds'],
          ),
          InvestmentStrategy(
            id: 'med_fixed_income_core',
            name: 'Pure Fixed Income Strategy',
            badgeText: '#3 DEFENSIVE',
            matchScore: 80,
            riskLevel: 'Low',
            suggestedHorizon: '3 - 4 Years',
            potentialGrowthRange: '7.2% - 8.0% p.a.',
            expectedReturnRate: 7.5,
            liquidity: 'Moderate',
            equityPercentage: 0,
            debtPercentage: 85,
            liquidPercentage: 15,
            whyItFits: 'Zero equity exposure for complete peace of mind.',
            whyItMayNotFit: 'Lower return requires higher monthly investment capacity.',
            recommendedCategories: ['Target Maturity Debt Funds', 'Corporate Bond Debt Funds', 'Fixed Deposits'],
            sampleInstruments: ['Target Maturity Bond Funds', 'AAA Corporate Debt'],
          ),
        ];
      }

      // Balanced or Growth risk for 2-5 years
      return [
        InvestmentStrategy(
          id: 'med_balanced_goal',
          name: 'Balanced Goal Strategy',
          badgeText: '#1 RECOMMENDED',
          matchScore: 94,
          riskLevel: 'Moderate',
          suggestedHorizon: '${yearsRemaining.toStringAsFixed(1)} Years',
          potentialGrowthRange: '10.5% - 12.5% p.a.',
          expectedReturnRate: 11.5,
          liquidity: 'High',
          equityPercentage: 50,
          debtPercentage: 35,
          liquidPercentage: 15,
          whyItFits: 'Optimal synergy between 50% equity wealth generation and 50% debt/liquid downside stability.',
          whyItMayNotFit: 'Requires staying invested across market corrections without panic selling.',
          recommendedCategories: ['Balanced Advantage Funds', 'Nifty 50 Large Cap Index', 'Short-Term Debt Funds'],
          sampleInstruments: ['Balanced Advantage Funds', 'Large Cap Index Funds', 'Corporate Debt Funds'],
        ),
        InvestmentStrategy(
          id: 'med_growth_accelerator',
          name: 'Aggressive Milestone Growth',
          badgeText: '#2 ALTERNATIVE',
          matchScore: 87,
          riskLevel: 'Moderate-High',
          suggestedHorizon: '4 - 5 Years',
          potentialGrowthRange: '12.5% - 14.5% p.a.',
          expectedReturnRate: 13.5,
          liquidity: 'High',
          equityPercentage: 70,
          debtPercentage: 25,
          liquidPercentage: 5,
          whyItFits: 'Accelerates goal accumulation by maximizing compounding equity exposure.',
          whyItMayNotFit: 'Higher drawdown risk if market correction happens near your target date.',
          recommendedCategories: ['Flexi-Cap Equity Funds', 'Large & Mid Cap Index', 'Corporate Bond Funds'],
          sampleInstruments: ['Flexi-Cap Mutual Funds', 'Nifty Next 50 Index', 'Short-Term Debt'],
        ),
        InvestmentStrategy(
          id: 'med_conservative_anchor',
          name: 'Conservative Capital Anchor',
          badgeText: '#3 DEFENSIVE',
          matchScore: 82,
          riskLevel: 'Low-Moderate',
          suggestedHorizon: '2 - 4 Years',
          potentialGrowthRange: '8.0% - 9.5% p.a.',
          expectedReturnRate: 8.8,
          liquidity: 'High',
          equityPercentage: 25,
          debtPercentage: 60,
          liquidPercentage: 15,
          whyItFits: 'Prioritizes goal certainty with only a gentle equity kicker.',
          whyItMayNotFit: 'Requires higher monthly SIP to reach target.',
          recommendedCategories: ['Conservative Hybrid Funds', 'High-Yield Bank FDs', 'Arbitrage Funds'],
          sampleInstruments: ['Conservative Hybrid Portfolios', 'Arbitrage Funds', 'AAA Debt Funds'],
        ),
      ];
    }

    // 3. LONG TERM & RETIREMENT (5 - 10+ Years)
    final isAggressive = (riskProfile == RiskProfileLevel.growth || riskProfile == RiskProfileLevel.aggressive);

    return [
      InvestmentStrategy(
        id: 'long_wealth_compounder',
        name: isAggressive ? 'Wealth Compounding Growth Strategy' : 'Strategic Long-Term Wealth Plan',
        badgeText: '#1 RECOMMENDED',
        matchScore: 96,
        riskLevel: isAggressive ? 'Moderate-High' : 'Moderate',
        suggestedHorizon: '${yearsRemaining.toStringAsFixed(0)}+ Years',
        potentialGrowthRange: isAggressive ? '13.0% - 15.5% p.a.' : '11.5% - 13.5% p.a.',
        expectedReturnRate: isAggressive ? 14.0 : 12.5,
        liquidity: 'High',
        equityPercentage: isAggressive ? 75 : 60,
        debtPercentage: isAggressive ? 20 : 30,
        liquidPercentage: isAggressive ? 5 : 10,
        whyItFits: 'Extensive ${yearsRemaining.toStringAsFixed(0)}-year runway easily absorbs short-term volatility, compounding substantial wealth.',
        whyItMayNotFit: 'Requires discipline to ignore temporary market headlines.',
        recommendedCategories: ['Nifty 50 & Next 50 Index Funds', 'Diversified Flexi-Cap Equities', 'Dynamic Debt Funds', 'Gold ETFs (5%)'],
        sampleInstruments: ['Nifty 50 Index Funds', 'Flexi-Cap Equity Funds', 'Target Maturity Debt', 'Sovereign Gold Bond / Gold ETF'],
      ),
      InvestmentStrategy(
        id: 'long_aggressive_alpha',
        name: 'Aggressive Alpha Multiplier',
        badgeText: '#2 ALTERNATIVE',
        matchScore: 89,
        riskLevel: 'High',
        suggestedHorizon: '7+ Years',
        potentialGrowthRange: '14.5% - 17.0% p.a.',
        expectedReturnRate: 15.5,
        liquidity: 'High',
        equityPercentage: 90,
        debtPercentage: 10,
        liquidPercentage: 0,
        whyItFits: 'Maximizes exposure to emerging mid & small caps for exponential long-term upside.',
        whyItMayNotFit: 'High drawdowns during bear markets (can drop 20-30% in single years).',
        recommendedCategories: ['Mid-Cap Index Funds', 'Small-Cap Active Funds', 'International Tech Equity'],
        sampleInstruments: ['Nifty Midcap 150 Index', 'Small Cap Mutual Funds', 'US Tech Equity ETFs'],
      ),
      InvestmentStrategy(
        id: 'long_all_weather_balanced',
        name: 'All-Weather Diversified Strategy',
        badgeText: '#3 DEFENSIVE',
        matchScore: 83,
        riskLevel: 'Moderate',
        suggestedHorizon: '5+ Years',
        potentialGrowthRange: '10.0% - 12.0% p.a.',
        expectedReturnRate: 11.0,
        liquidity: 'High',
        equityPercentage: 45,
        debtPercentage: 40,
        liquidPercentage: 15,
        whyItFits: 'Smooths out returns through all economic cycles using a 45/40/15 equity-debt-gold blend.',
        whyItMayNotFit: 'Underperforms pure equities in strong bull market runs.',
        recommendedCategories: ['Multi-Asset Allocation Funds', 'Large Cap Index', 'Corporate Bonds', 'Gold / Commodities'],
        sampleInstruments: ['Multi-Asset Allocation Funds', 'Nifty 50 Index', 'Physical Gold ETFs'],
      ),
    ];
  }

  // ============================================================
  // 4. DYNAMIC AI EXPLANATION & RECOMMENDATION GENERATORS
  // ============================================================

  static String _generateAiGoalAnalysis({
    required InvestmentGoalType goalType,
    required double targetAmount,
    required double yearsRemaining,
    required RiskProfileLevel riskProfile,
    required double monthlyCapacity,
    required double requiredMonthly,
    required InvestmentStrategy strategy,
  }) {
    final targetLakhs = (targetAmount / 100000).toStringAsFixed(1);
    final horizonStr = yearsRemaining < 1
        ? '${(yearsRemaining * 12).toInt()} months'
        : '${yearsRemaining.toStringAsFixed(1)} years';

    final capacityDiff = monthlyCapacity - requiredMonthly;
    final bufferText = capacityDiff >= 0
        ? 'Your monthly capacity of ₹${monthlyCapacity.toStringAsFixed(0)} comfortably covers the estimated requirement (₹${requiredMonthly.toStringAsFixed(0)}/mo).'
        : 'Your current capacity of ₹${monthlyCapacity.toStringAsFixed(0)} is below the recommended ₹${requiredMonthly.toStringAsFixed(0)}/mo. You may consider extending the target timeline or stepping up contributions annually.';

    if (goalType == InvestmentGoalType.emergency) {
      return 'FinPilot AI Analysis: For an essential Emergency Fund (₹${targetLakhs}L in $horizonStr), capital stability and instant liquidity take 100% priority. Equity exposure is intentionally eliminated to avoid any risk of capital drawdowns when urgent funds are needed.';
    }

    if (goalType == InvestmentGoalType.taxSaving) {
      return 'FinPilot AI Analysis: For your Section 80C Tax-Saving goal, FinPilot balances statutory tax deductions with long-term compounding. We prioritize ELSS mutual funds due to their low 3-year lock-in and superior equity growth potential compared to 15-year traditional instruments.';
    }

    return 'FinPilot AI Analysis: Based on your ₹${targetLakhs}L ${goalType.displayName.toLowerCase()} goal in $horizonStr, your ${riskProfile.displayName} risk profile, and your financial parameters, FinPilot recommends the "${strategy.name}". This allocates ${strategy.equityPercentage.toInt()}% into diversified equity for growth, balanced with ${strategy.debtPercentage.toInt()}% debt and ${strategy.liquidPercentage.toInt()}% liquid reserves for stability. $bufferText';
  }

  static String _generateAiRecommendationSummary({
    required InvestmentGoalType goalType,
    required double yearsRemaining,
    required RiskProfileLevel riskProfile,
    required double requiredMonthly,
    required InvestmentStrategy strategy,
    required String feasibilityLabel,
  }) {
    final horizonStr = yearsRemaining < 1
        ? '${(yearsRemaining * 12).toInt()} months'
        : '${yearsRemaining.toStringAsFixed(0)} years';

    return 'FinPilot Recommendation:\n'
        '• Strongest Fit: ${strategy.name} (AI Match: ${strategy.matchScore}%)\n'
        '• Suggested Allocation: ${strategy.equityPercentage.toInt()}% Equity, ${strategy.debtPercentage.toInt()}% Debt, ${strategy.liquidPercentage.toInt()}% Liquid\n'
        '• Action Plan: Deploy approximately ₹${requiredMonthly.toStringAsFixed(0)}/month into the suggested asset categories.\n'
        '• Status: $feasibilityLabel for your $horizonStr horizon with a ${riskProfile.displayName} profile.\n'
        '• Best Practice: Review your portfolio annually and de-risk into liquid funds during the final 6–12 months before your target date.';
  }

  // ============================================================
  // 5. "WHAT IF?" SCENARIO CALCULATOR
  // ============================================================

  static List<WhatIfScenario> generateWhatIfScenarios({
    required double targetAmount,
    required double currentSavings,
    required int monthsRemaining,
    required double monthlyCapacity,
    required double expectedAnnualRate,
  }) {
    final scenarios = <WhatIfScenario>[];

    // Scenario 1: Invest ₹5,000 more per month
    final extraSip = 5000.0;
    final fvWithExtra = calculateFutureValue(
      currentSavings: currentSavings,
      monthlyContribution: monthlyCapacity + extraSip,
      monthsRemaining: monthsRemaining,
      annualRate: expectedAnnualRate,
    );
    final extraWealth = fvWithExtra - calculateFutureValue(
      currentSavings: currentSavings,
      monthlyContribution: monthlyCapacity,
      monthsRemaining: monthsRemaining,
      annualRate: expectedAnnualRate,
    );
    scenarios.add(WhatIfScenario(
      title: 'Invest +₹5,000 / month',
      actionDescription: 'Increase monthly contribution by ₹5,000',
      modifiedMonthlyRequired: monthlyCapacity + extraSip,
      modifiedMonths: monthsRemaining,
      estimatedFinalValue: fvWithExtra,
      probabilityOutcome: 'Probability increases to 96%',
      impactSummary: 'Adds ~₹${(extraWealth / 1000).toStringAsFixed(0)}k extra wealth at maturity!',
    ));

    // Scenario 2: Delay goal by 1 Year (+12 months)
    final extendedMonths = monthsRemaining + 12;
    final newRequiredWithDelay = calculateRequiredMonthlyInvestment(
      targetAmount: targetAmount,
      currentSavings: currentSavings,
      monthsRemaining: extendedMonths,
      annualRate: expectedAnnualRate,
    );
    scenarios.add(WhatIfScenario(
      title: 'Delay goal by 1 year',
      actionDescription: 'Extend timeline by +12 months to lower pressure',
      modifiedMonthlyRequired: newRequiredWithDelay,
      modifiedMonths: extendedMonths,
      estimatedFinalValue: targetAmount,
      probabilityOutcome: 'Achievability becomes High',
      impactSummary: 'Lowers required monthly SIP to ₹${newRequiredWithDelay.toStringAsFixed(0)}/mo.',
    ));

    // Scenario 3: Start with ₹50,000 upfront today
    final boostedSavings = currentSavings + 50000.0;
    final newRequiredWithLumpsum = calculateRequiredMonthlyInvestment(
      targetAmount: targetAmount,
      currentSavings: boostedSavings,
      monthsRemaining: monthsRemaining,
      annualRate: expectedAnnualRate,
    );
    scenarios.add(WhatIfScenario(
      title: 'Add ₹50,000 today',
      actionDescription: 'Deploy ₹50k upfront lump sum immediately',
      modifiedMonthlyRequired: newRequiredWithLumpsum,
      modifiedMonths: monthsRemaining,
      estimatedFinalValue: targetAmount,
      probabilityOutcome: 'Immediate headstart',
      impactSummary: 'Reduces monthly SIP burden by ~₹${math.max(0, (targetAmount - boostedSavings) / monthsRemaining * 0.2).toStringAsFixed(0)}/mo.',
    ));

    // Scenario 4: Returns are 2% lower than expected
    final lowerRate = math.max(4.0, expectedAnnualRate - 2.0);
    final newRequiredLowerReturn = calculateRequiredMonthlyInvestment(
      targetAmount: targetAmount,
      currentSavings: currentSavings,
      monthsRemaining: monthsRemaining,
      annualRate: lowerRate,
    );
    scenarios.add(WhatIfScenario(
      title: 'Market returns 2% lower',
      actionDescription: 'Stress-test plan at ${lowerRate.toStringAsFixed(1)}% p.a.',
      modifiedMonthlyRequired: newRequiredLowerReturn,
      modifiedMonths: monthsRemaining,
      estimatedFinalValue: targetAmount,
      probabilityOutcome: 'Conservative safety test',
      impactSummary: 'Requires ₹${newRequiredLowerReturn.toStringAsFixed(0)}/mo to ensure target is met.',
    ));

    return scenarios;
  }

  // ============================================================
  // 6. GOAL-AWARE AI CHAT ASSISTANT ENGINE
  // ============================================================

  static String getAiChatAnswer({
    required String question,
    required AiInvestmentPlan plan,
  }) {
    final q = question.toLowerCase();
    final targetLakhs = (plan.targetAmount / 100000).toStringAsFixed(1);
    final years = (plan.monthsRemaining / 12).toStringAsFixed(1);

    if (q.contains('car') || q.contains('buy a car')) {
      return 'For your ₹${targetLakhs}L Car goal in $years years, FinPilot recommends prioritizing moderate volatility. Since car down payments have fixed dates, allocating at least 35% in debt and liquid funds guarantees you won’t have to delay purchase if markets temporarily dip. Required SIP: ₹${plan.requiredMonthlyContribution.toStringAsFixed(0)}/month.';
    }

    if (q.contains('10,000') || q.contains('where should i invest') || q.contains('where to invest')) {
      final strat = plan.selectedStrategy;
      return 'With ₹10,000/month for your ${plan.goalTitle}, FinPilot recommends dividing it into your ${strat.name} strategy:\n'
          '• ₹${(10000 * (strat.equityPercentage / 100)).toStringAsFixed(0)} in ${strat.recommendedCategories.first}\n'
          '• ₹${(10000 * (strat.debtPercentage / 100)).toStringAsFixed(0)} in ${strat.recommendedCategories.length > 1 ? strat.recommendedCategories[1] : "Debt Mutual Funds"}\n'
          '• ₹${(10000 * (strat.liquidPercentage / 100)).toStringAsFixed(0)} in Liquid / Arbitrage buffer.';
    }

    if (q.contains('retirement') || q.contains('retire')) {
      return 'For Retirement planning, time is your greatest asset. With an investment horizon of 15–25 years, market cycles average out, allowing 70–80% allocation into diversified Nifty Index funds and Flexi-Cap equities to build an inflation-proof multi-crore corpus.';
    }

    if (q.contains('safer') || q.contains('safe') || q.contains('conservative')) {
      return 'Choosing a safer, lower-risk strategy will protect your capital from market swings. However, because expected returns decrease from ~12% to ~7.5%, your required monthly investment will increase from ₹${plan.requiredMonthlyContribution.toStringAsFixed(0)} to approximately ₹${(plan.requiredMonthlyContribution * 1.25).toStringAsFixed(0)}/month to reach the same ₹${targetLakhs}L target.';
    }

    if (q.contains('20 lakh') || q.contains('reach')) {
      final reqFor20L = calculateRequiredMonthlyInvestment(
        targetAmount: 2000000,
        currentSavings: plan.currentSavings,
        monthsRemaining: 60,
        annualRate: 12.0,
      );
      return 'To accumulate ₹20 Lakhs in 5 years at an expected 12% p.a. return, you would need to invest approximately ₹${reqFor20L.toStringAsFixed(0)}/month starting today with a balanced equity-debt allocation.';
    }

    return 'FinPilot AI Analysis: For your ${plan.goalTitle} goal (Target: ₹${targetLakhs}L in $years years), your optimal strategy is "${plan.selectedStrategy.name}". Maintain a regular monthly contribution of ₹${plan.requiredMonthlyContribution.toStringAsFixed(0)}, review asset allocation once a year, and transition into liquid funds as your target date approaches.';
  }
}
