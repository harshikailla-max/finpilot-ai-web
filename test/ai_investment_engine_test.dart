import 'package:flutter_test/flutter_test.dart';
import 'package:finpilot_ai/models/ai_investment_goal_plan.dart';
import 'package:finpilot_ai/services/ai_investment_engine.dart';

void main() {
  group('AiInvestmentEngine — Mathematical Calculations', () {
    test('calculateRequiredMonthlyInvestment handles target already met', () {
      final req = AiInvestmentEngine.calculateRequiredMonthlyInvestment(
        targetAmount: 500000,
        currentSavings: 500000,
        monthsRemaining: 24,
        annualRate: 10.0,
      );
      expect(req, equals(0.0));
    });

    test('calculateRequiredMonthlyInvestment handles zero return rate via simple linear division', () {
      final req = AiInvestmentEngine.calculateRequiredMonthlyInvestment(
        targetAmount: 240000,
        currentSavings: 0,
        monthsRemaining: 24,
        annualRate: 0.0,
      );
      expect(req, equals(10000.0));
    });

    test('calculateRequiredMonthlyInvestment with compounding annuity PMT formula', () {
      final req = AiInvestmentEngine.calculateRequiredMonthlyInvestment(
        targetAmount: 1000000,
        currentSavings: 100000,
        monthsRemaining: 36,
        annualRate: 12.0,
      );
      expect(req, greaterThan(18000));
      expect(req, lessThan(22000));
    });

    test('calculateFutureValue computes correct compounded SIP returns', () {
      final fv = AiInvestmentEngine.calculateFutureValue(
        currentSavings: 0,
        monthlyContribution: 10000,
        monthsRemaining: 12,
        annualRate: 12.0,
      );
      // Principal = 120,000. With monthly compounding, fv > 125,000
      expect(fv, greaterThan(125000));
      expect(fv, lessThan(130000));
    });

    test('calculateGoalProbability returns 98% when capacity comfortably exceeds required', () {
      final prob = AiInvestmentEngine.calculateGoalProbability(
        monthlyCapacity: 50000,
        requiredMonthly: 20000,
      );
      expect(prob, equals(98));
    });

    test('calculateGoalProbability returns lower probability when capacity is deficient', () {
      final prob = AiInvestmentEngine.calculateGoalProbability(
        monthlyCapacity: 10000,
        requiredMonthly: 30000,
      );
      expect(prob, lessThan(50));
      expect(prob, greaterThanOrEqualTo(10));
    });
  });

  group('AiInvestmentEngine — Risk Profiler & Questionnaire', () {
    test('evaluateRiskScore correctly categorizes Conservative (<=35)', () {
      final level = AiInvestmentEngine.evaluateRiskScore(25);
      expect(level, equals(RiskProfileLevel.conservative));
    });

    test('evaluateRiskScore correctly categorizes Balanced (36 to 65)', () {
      final level = AiInvestmentEngine.evaluateRiskScore(50);
      expect(level, equals(RiskProfileLevel.balanced));
    });

    test('evaluateRiskScore correctly categorizes Growth (66 to 85)', () {
      final level = AiInvestmentEngine.evaluateRiskScore(75);
      expect(level, equals(RiskProfileLevel.growth));
    });

    test('evaluateRiskScore correctly categorizes Aggressive (>85)', () {
      final level = AiInvestmentEngine.evaluateRiskScore(90);
      expect(level, equals(RiskProfileLevel.aggressive));
    });

    test('risk questions are available and properly structured', () {
      final questions = AiInvestmentEngine.getRiskQuestions();
      expect(questions.length, equals(5));
      for (final q in questions) {
        expect(q.options.length, greaterThanOrEqualTo(3));
        for (final opt in q.options) {
          expect(opt.points, inInclusiveRange(0, 100));
        }
      }
    });
  });

  group('AiInvestmentEngine — Goal Strategies & Special Rules', () {
    test('Emergency Fund goal enforces 0% equity allocation across all strategies', () {
      final plan = AiInvestmentEngine.buildPlan(
        goalType: InvestmentGoalType.emergency,
        goalTitle: 'Safety Net',
        targetAmount: 300000,
        currentSavings: 50000,
        monthlyCapacity: 20000,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        riskProfile: RiskProfileLevel.aggressive, // Even if user is aggressive, emergency fund must stay safe
        manualRiskScore: 90,
      );

      expect(plan.selectedStrategy.equityPercentage, equals(0));
      for (final s in plan.allStrategies) {
        expect(s.equityPercentage, equals(0));
        expect(s.debtPercentage + s.liquidPercentage, equals(100));
      }
    });

    test('Tax Saving goal recommends ELSS and Section 80C options', () {
      final plan = AiInvestmentEngine.buildPlan(
        goalType: InvestmentGoalType.taxSaving,
        goalTitle: 'FY25 Tax Optimization',
        targetAmount: 150000,
        currentSavings: 0,
        monthlyCapacity: 12500,
        targetDate: DateTime.now().add(const Duration(days: 365 * 3)),
        riskProfile: RiskProfileLevel.growth,
        manualRiskScore: 70,
      );

      final rec = plan.selectedStrategy;
      expect(rec.recommendedCategories.any((c) => c.contains('ELSS') || c.contains('80C')), isTrue);
      expect(rec.whyItFits.contains('Section 80C') || rec.whyItFits.contains('80C'), isTrue);
    });

    test('Short-term goals (<2 years) enforce low equity exposure', () {
      final plan = AiInvestmentEngine.buildPlan(
        goalType: InvestmentGoalType.travel,
        goalTitle: 'Europe Trip',
        targetAmount: 300000,
        currentSavings: 50000,
        monthlyCapacity: 25000,
        targetDate: DateTime.now().add(const Duration(days: 300)),
        riskProfile: RiskProfileLevel.aggressive,
        manualRiskScore: 85,
      );

      expect(plan.selectedStrategy.equityPercentage, lessThanOrEqualTo(10));
    });

    test('Long-term wealth goal allocates high equity for growth', () {
      final plan = AiInvestmentEngine.buildPlan(
        goalType: InvestmentGoalType.wealth,
        goalTitle: 'Long Term Wealth',
        targetAmount: 5000000,
        currentSavings: 200000,
        monthlyCapacity: 50000,
        targetDate: DateTime.now().add(const Duration(days: 365 * 8)),
        riskProfile: RiskProfileLevel.aggressive,
        manualRiskScore: 85,
      );

      expect(plan.selectedStrategy.equityPercentage, greaterThanOrEqualTo(60));
    });

    test('buildPlan produces exactly 3 distinct ranked strategies', () {
      final plan = AiInvestmentEngine.buildPlan(
        goalType: InvestmentGoalType.car,
        goalTitle: 'Buy SUV',
        targetAmount: 1200000,
        currentSavings: 200000,
        monthlyCapacity: 30000,
        targetDate: DateTime.now().add(const Duration(days: 365 * 3)),
        riskProfile: RiskProfileLevel.balanced,
        manualRiskScore: 55,
      );

      expect(plan.allStrategies.length, equals(3));
      expect(plan.allStrategies[0].badgeText, equals('#1 RECOMMENDED'));
      expect(plan.allStrategies[1].badgeText, equals('#2 ALTERNATIVE'));
      expect(plan.allStrategies[2].badgeText, equals('#3 DEFENSIVE'));
    });
  });

  group('AiInvestmentEngine — What-If Scenarios and AI Copilot', () {
    test('generateWhatIfScenarios outputs 4 distinct actionable scenarios', () {
      final scenarios = AiInvestmentEngine.generateWhatIfScenarios(
        targetAmount: 2000000,
        currentSavings: 300000,
        monthlyCapacity: 35000,
        monthsRemaining: 48,
        expectedAnnualRate: 11.5,
      );

      expect(scenarios.length, equals(4));
      expect(scenarios[0].title, contains('+₹5,000'));
      expect(scenarios[1].title, contains('Delay goal by 1 year'));
      expect(scenarios[2].title, contains('Add ₹50,000 today'));
      expect(scenarios[3].title, contains('Market returns 2% lower'));
    });

    test('getAiChatAnswer delivers context-aware response for preset questions', () {
      final plan = AiInvestmentEngine.buildPlan(
        goalType: InvestmentGoalType.car,
        goalTitle: 'Buy SUV',
        targetAmount: 1000000,
        currentSavings: 100000,
        monthlyCapacity: 25000,
        targetDate: DateTime.now().add(const Duration(days: 365 * 3)),
        riskProfile: RiskProfileLevel.balanced,
        manualRiskScore: 55,
      );

      final answer = AiInvestmentEngine.getAiChatAnswer(
        plan: plan,
        question: 'Should I choose a safer, lower-risk strategy?',
      );

      expect(answer, isNotEmpty);
      expect(answer.contains('safer') || answer.contains('risk'), isTrue);
    });
  });

  group('AiInvestmentPlan — Serialization', () {
    test('plan correctly serializes and deserializes through toMap and fromMap', () {
      final originalPlan = AiInvestmentEngine.buildPlan(
        goalType: InvestmentGoalType.education,
        goalTitle: 'Masters Degree',
        targetAmount: 2500000,
        currentSavings: 400000,
        monthlyCapacity: 45000,
        targetDate: DateTime.now().add(const Duration(days: 365 * 4)),
        riskProfile: RiskProfileLevel.growth,
        manualRiskScore: 68,
      );

      final map = originalPlan.toMap();
      final restoredPlan = AiInvestmentPlan.fromMap(map);

      expect(restoredPlan.goalType, equals(originalPlan.goalType));
      expect(restoredPlan.goalTitle, equals(originalPlan.goalTitle));
      expect(restoredPlan.targetAmount, equals(originalPlan.targetAmount));
      expect(restoredPlan.currentSavings, equals(originalPlan.currentSavings));
      expect(restoredPlan.monthlyCapacity, equals(originalPlan.monthlyCapacity));
      expect(restoredPlan.riskProfile, equals(originalPlan.riskProfile));
      expect(restoredPlan.allStrategies.length, equals(3));
      expect(restoredPlan.selectedStrategy.name, equals(originalPlan.selectedStrategy.name));
    });
  });
}
