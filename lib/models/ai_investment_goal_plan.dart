import 'dart:convert';
import 'package:flutter/material.dart';

enum InvestmentGoalType {
  car,
  home,
  education,
  travel,
  marriage,
  emergency,
  wealth,
  retirement,
  taxSaving,
  custom,
}

extension InvestmentGoalTypeExtension on InvestmentGoalType {
  String get displayName {
    switch (this) {
      case InvestmentGoalType.car:
        return 'Buy a Car';
      case InvestmentGoalType.home:
        return 'Home Down Payment';
      case InvestmentGoalType.education:
        return 'Higher Education';
      case InvestmentGoalType.travel:
        return 'Vacation';
      case InvestmentGoalType.marriage:
        return 'Wedding';
      case InvestmentGoalType.emergency:
        return 'Emergency Fund';
      case InvestmentGoalType.wealth:
        return 'Wealth Creation';
      case InvestmentGoalType.retirement:
        return 'Retirement';
      case InvestmentGoalType.taxSaving:
        return 'Tax Saving';
      case InvestmentGoalType.custom:
        return 'Custom Goal';
    }
  }

  String get shortName {
    switch (this) {
      case InvestmentGoalType.car:
        return 'Car';
      case InvestmentGoalType.home:
        return 'Home';
      case InvestmentGoalType.education:
        return 'Education';
      case InvestmentGoalType.travel:
        return 'Travel';
      case InvestmentGoalType.marriage:
        return 'Wedding';
      case InvestmentGoalType.emergency:
        return 'Emergency';
      case InvestmentGoalType.wealth:
        return 'Wealth';
      case InvestmentGoalType.retirement:
        return 'Retirement';
      case InvestmentGoalType.taxSaving:
        return 'Tax Saving';
      case InvestmentGoalType.custom:
        return 'Custom';
    }
  }

  String get emoji {
    switch (this) {
      case InvestmentGoalType.car:
        return '🚗';
      case InvestmentGoalType.home:
        return '🏠';
      case InvestmentGoalType.education:
        return '🎓';
      case InvestmentGoalType.travel:
        return '✈️';
      case InvestmentGoalType.marriage:
        return '💍';
      case InvestmentGoalType.emergency:
        return '🛡️';
      case InvestmentGoalType.wealth:
        return '🌱';
      case InvestmentGoalType.retirement:
        return '🏖️';
      case InvestmentGoalType.taxSaving:
        return '💰';
      case InvestmentGoalType.custom:
        return '✨';
    }
  }

  String get description {
    switch (this) {
      case InvestmentGoalType.car:
        return 'Down payment or purchase of a dream vehicle';
      case InvestmentGoalType.home:
        return 'Accumulate home loan down payment & registry fees';
      case InvestmentGoalType.education:
        return 'Fund degree, certifications, or child education';
      case InvestmentGoalType.travel:
        return 'Domestic or international holiday funding';
      case InvestmentGoalType.marriage:
        return 'Wedding celebrations & jewelry funding';
      case InvestmentGoalType.emergency:
        return '3–6 months essential living expense safety buffer';
      case InvestmentGoalType.wealth:
        return 'Long-term compounding & financial independence';
      case InvestmentGoalType.retirement:
        return 'Golden years corpus for inflation-proof living';
      case InvestmentGoalType.taxSaving:
        return 'Maximize Section 80C deductions & wealth accumulation';
      case InvestmentGoalType.custom:
        return 'Personalized financial milestones';
    }
  }

  double get defaultTargetAmount {
    switch (this) {
      case InvestmentGoalType.car:
        return 1000000;
      case InvestmentGoalType.home:
        return 2500000;
      case InvestmentGoalType.education:
        return 1500000;
      case InvestmentGoalType.travel:
        return 200000;
      case InvestmentGoalType.marriage:
        return 1200000;
      case InvestmentGoalType.emergency:
        return 300000;
      case InvestmentGoalType.wealth:
        return 5000000;
      case InvestmentGoalType.retirement:
        return 10000000;
      case InvestmentGoalType.taxSaving:
        return 150000;
      case InvestmentGoalType.custom:
        return 500000;
    }
  }

  int get defaultYears {
    switch (this) {
      case InvestmentGoalType.car:
        return 3;
      case InvestmentGoalType.home:
        return 5;
      case InvestmentGoalType.education:
        return 4;
      case InvestmentGoalType.travel:
        return 1;
      case InvestmentGoalType.marriage:
        return 3;
      case InvestmentGoalType.emergency:
        return 1;
      case InvestmentGoalType.wealth:
        return 10;
      case InvestmentGoalType.retirement:
        return 20;
      case InvestmentGoalType.taxSaving:
        return 3;
      case InvestmentGoalType.custom:
        return 3;
    }
  }
}

enum RiskProfileLevel {
  conservative,
  balanced,
  growth,
  aggressive,
}

extension RiskProfileLevelExtension on RiskProfileLevel {
  String get displayName {
    switch (this) {
      case RiskProfileLevel.conservative:
        return 'Conservative';
      case RiskProfileLevel.balanced:
        return 'Balanced';
      case RiskProfileLevel.growth:
        return 'Growth';
      case RiskProfileLevel.aggressive:
        return 'Aggressive';
    }
  }

  String get summary {
    switch (this) {
      case RiskProfileLevel.conservative:
        return 'Capital preservation is top priority. Prefer lower but stable, predictable returns.';
      case RiskProfileLevel.balanced:
        return 'Prefer solid growth while keeping downside fluctuations moderate and controlled.';
      case RiskProfileLevel.growth:
        return 'Willing to accept moderate-to-high volatility in exchange for market-beating returns.';
      case RiskProfileLevel.aggressive:
        return 'Comfortable with large market swings to maximize long-term compounding wealth.';
    }
  }

  Color get color {
    switch (this) {
      case RiskProfileLevel.conservative:
        return const Color(0xFF4CC9F0);
      case RiskProfileLevel.balanced:
        return const Color(0xFF6C5CE7);
      case RiskProfileLevel.growth:
        return const Color(0xFF2DD4A8);
      case RiskProfileLevel.aggressive:
        return const Color(0xFFFFB86B);
    }
  }
}

class RiskQuestion {
  final String id;
  final String question;
  final List<RiskOption> options;

  RiskQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class RiskOption {
  final String label;
  final int points;

  RiskOption({required this.label, required this.points});
}

class InvestmentStrategy {
  final String id;
  final String name;
  final String badgeText;
  final int matchScore; // 0 to 100
  final String riskLevel; // 'Low', 'Low-Moderate', 'Moderate', 'Moderate-High', 'High'
  final String suggestedHorizon;
  final String potentialGrowthRange; // e.g. "11% - 13% p.a."
  final double expectedReturnRate; // e.g. 12.0
  final String liquidity; // 'High', 'Moderate', 'Locked (3 yrs)', etc.
  final double equityPercentage;
  final double debtPercentage;
  final double liquidPercentage;
  final String whyItFits;
  final String whyItMayNotFit;
  final List<String> recommendedCategories;
  final List<String> sampleInstruments;

  InvestmentStrategy({
    required this.id,
    required this.name,
    required this.badgeText,
    required this.matchScore,
    required this.riskLevel,
    required this.suggestedHorizon,
    required this.potentialGrowthRange,
    required this.expectedReturnRate,
    required this.liquidity,
    required this.equityPercentage,
    required this.debtPercentage,
    required this.liquidPercentage,
    required this.whyItFits,
    required this.whyItMayNotFit,
    required this.recommendedCategories,
    required this.sampleInstruments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'badgeText': badgeText,
      'matchScore': matchScore,
      'riskLevel': riskLevel,
      'suggestedHorizon': suggestedHorizon,
      'potentialGrowthRange': potentialGrowthRange,
      'expectedReturnRate': expectedReturnRate,
      'liquidity': liquidity,
      'equityPercentage': equityPercentage,
      'debtPercentage': debtPercentage,
      'liquidPercentage': liquidPercentage,
      'whyItFits': whyItFits,
      'whyItMayNotFit': whyItMayNotFit,
      'recommendedCategories': recommendedCategories,
      'sampleInstruments': sampleInstruments,
    };
  }

  factory InvestmentStrategy.fromMap(Map<String, dynamic> map) {
    return InvestmentStrategy(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      badgeText: map['badgeText']?.toString() ?? '',
      matchScore: (map['matchScore'] as num?)?.toInt() ?? 80,
      riskLevel: map['riskLevel']?.toString() ?? 'Moderate',
      suggestedHorizon: map['suggestedHorizon']?.toString() ?? '',
      potentialGrowthRange: map['potentialGrowthRange']?.toString() ?? '',
      expectedReturnRate: (map['expectedReturnRate'] as num?)?.toDouble() ?? 10.0,
      liquidity: map['liquidity']?.toString() ?? 'Moderate',
      equityPercentage: (map['equityPercentage'] as num?)?.toDouble() ?? 40.0,
      debtPercentage: (map['debtPercentage'] as num?)?.toDouble() ?? 40.0,
      liquidPercentage: (map['liquidPercentage'] as num?)?.toDouble() ?? 20.0,
      whyItFits: map['whyItFits']?.toString() ?? '',
      whyItMayNotFit: map['whyItMayNotFit']?.toString() ?? '',
      recommendedCategories: List<String>.from(map['recommendedCategories'] ?? []),
      sampleInstruments: List<String>.from(map['sampleInstruments'] ?? []),
    );
  }
}

class WhatIfScenario {
  final String title;
  final String actionDescription;
  final double modifiedMonthlyRequired;
  final int modifiedMonths;
  final double estimatedFinalValue;
  final String probabilityOutcome;
  final String impactSummary;

  WhatIfScenario({
    required this.title,
    required this.actionDescription,
    required this.modifiedMonthlyRequired,
    required this.modifiedMonths,
    required this.estimatedFinalValue,
    required this.probabilityOutcome,
    required this.impactSummary,
  });
}

class AiInvestmentPlan {
  final String id;
  final InvestmentGoalType goalType;
  final String goalTitle;
  final double targetAmount;
  final DateTime targetDate;
  final double currentSavings;
  final double monthlyCapacity;
  final RiskProfileLevel riskProfile;
  final int riskScore;
  final InvestmentStrategy selectedStrategy;
  final List<InvestmentStrategy> allStrategies;
  final double requiredMonthlyContribution;
  final double remainingDeficit;
  final int monthsRemaining;
  final bool isAchievable;
  final String feasibilityLabel; // 'Achievable', 'Requires Adjustment', 'High Deficit'
  final String aiAnalysisText;
  final String aiRecommendationSummary;
  final DateTime createdAt;

  AiInvestmentPlan({
    required this.id,
    required this.goalType,
    required this.goalTitle,
    required this.targetAmount,
    required this.targetDate,
    required this.currentSavings,
    required this.monthlyCapacity,
    required this.riskProfile,
    required this.riskScore,
    required this.selectedStrategy,
    required this.allStrategies,
    required this.requiredMonthlyContribution,
    required this.remainingDeficit,
    required this.monthsRemaining,
    required this.isAchievable,
    required this.feasibilityLabel,
    required this.aiAnalysisText,
    required this.aiRecommendationSummary,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalType': goalType.name,
      'goalTitle': goalTitle,
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'currentSavings': currentSavings,
      'monthlyCapacity': monthlyCapacity,
      'riskProfile': riskProfile.name,
      'riskScore': riskScore,
      'selectedStrategy': selectedStrategy.toMap(),
      'allStrategies': allStrategies.map((s) => s.toMap()).toList(),
      'requiredMonthlyContribution': requiredMonthlyContribution,
      'remainingDeficit': remainingDeficit,
      'monthsRemaining': monthsRemaining,
      'isAchievable': isAchievable,
      'feasibilityLabel': feasibilityLabel,
      'aiAnalysisText': aiAnalysisText,
      'aiRecommendationSummary': aiRecommendationSummary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AiInvestmentPlan.fromMap(Map<String, dynamic> map) {
    InvestmentGoalType parsedGoal = InvestmentGoalType.car;
    try {
      parsedGoal = InvestmentGoalType.values.byName(map['goalType']?.toString() ?? 'car');
    } catch (_) {}

    RiskProfileLevel parsedRisk = RiskProfileLevel.balanced;
    try {
      parsedRisk = RiskProfileLevel.values.byName(map['riskProfile']?.toString() ?? 'balanced');
    } catch (_) {}

    final stratMap = map['selectedStrategy'] as Map<String, dynamic>? ?? {};
    final stratsList = (map['allStrategies'] as List<dynamic>?)
            ?.map((e) => InvestmentStrategy.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AiInvestmentPlan(
      id: map['id']?.toString() ?? '',
      goalType: parsedGoal,
      goalTitle: map['goalTitle']?.toString() ?? parsedGoal.displayName,
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 1000000,
      targetDate: DateTime.tryParse(map['targetDate']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 365 * 3)),
      currentSavings: (map['currentSavings'] as num?)?.toDouble() ?? 0,
      monthlyCapacity: (map['monthlyCapacity'] as num?)?.toDouble() ?? 15000,
      riskProfile: parsedRisk,
      riskScore: (map['riskScore'] as num?)?.toInt() ?? 50,
      selectedStrategy: InvestmentStrategy.fromMap(stratMap),
      allStrategies: stratsList,
      requiredMonthlyContribution:
          (map['requiredMonthlyContribution'] as num?)?.toDouble() ?? 20000,
      remainingDeficit: (map['remainingDeficit'] as num?)?.toDouble() ?? 1000000,
      monthsRemaining: (map['monthsRemaining'] as num?)?.toInt() ?? 36,
      isAchievable: map['isAchievable'] as bool? ?? true,
      feasibilityLabel: map['feasibilityLabel']?.toString() ?? 'Achievable',
      aiAnalysisText: map['aiAnalysisText']?.toString() ?? '',
      aiRecommendationSummary: map['aiRecommendationSummary']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory AiInvestmentPlan.fromJson(String source) =>
      AiInvestmentPlan.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
