import 'package:flutter_test/flutter_test.dart';
import 'package:finpilot_ai/services/financial_calculator_service.dart';
import 'package:finpilot_ai/models/financial_goal.dart';
import 'package:finpilot_ai/models/investment_model.dart';

void main() {
  group('FinancialCalculatorService — Car Affordability', () {
    test('user with savings >= down payment and capacity can afford car', () {
      final result = FinancialCalculatorService.calculateCarAffordability(
        carPrice: 800000,
        currentSavings: 200000,
        targetMonths: 12,
        downPaymentPercentage: 20,
        annualInterestRate: 9.0,
        loanTenureYears: 3,
        monthlyIncome: 80000,
        monthlyExpenses: 40000,
      );
      expect(result.isFeasible, isTrue);
    });

    test('user with insufficient savings and income cannot afford car', () {
      final result = FinancialCalculatorService.calculateCarAffordability(
        carPrice: 2000000,
        currentSavings: 10000,
        targetMonths: 12,
        downPaymentPercentage: 20,
        annualInterestRate: 10.0,
        loanTenureYears: 5,
        monthlyIncome: 30000,
        monthlyExpenses: 29000,
      );
      expect(result.isFeasible, isFalse);
    });

    test('monthly EMI is calculated correctly for loan amount', () {
      final result = FinancialCalculatorService.calculateCarAffordability(
        carPrice: 800000,
        currentSavings: 200000,
        targetMonths: 12,
        downPaymentPercentage: 20,
        annualInterestRate: 9.0,
        loanTenureYears: 3,
        monthlyIncome: 100000,
        monthlyExpenses: 40000,
      );
      expect(result.estimatedEmi, greaterThan(0));
    });
  });

  group('FinancialCalculatorService — Health Score', () {
    test('high savings rate and emergency fund yields good health score', () {
      final res = FinancialCalculatorService.calculateFinancialHealth(
        monthlyIncome: 100000,
        monthlyExpenses: 40000,
        currentBalance: 300000,
        totalDebtEmi: 5000,
        goals: [
          FinancialGoal(
            id: 'g1',
            title: 'Vacation',
            targetAmount: 50000,
            currentAmount: 25000,
            targetDate: DateTime.now().add(const Duration(days: 100)),
            category: GoalCategory.travel,
            priority: GoalPriority.medium,
            createdDate: DateTime.now(),
          ),
        ],
      );
      expect(res['score'], greaterThanOrEqualTo(60));
    });

    test('no savings and high debt yields poor health score', () {
      final res = FinancialCalculatorService.calculateFinancialHealth(
        monthlyIncome: 30000,
        monthlyExpenses: 30000,
        currentBalance: 0,
        totalDebtEmi: 20000,
        goals: [],
      );
      expect(res['score'], lessThan(50));
    });

    test('health score is always between 0 and 100', () {
      final extremeHighScore = FinancialCalculatorService.calculateFinancialHealth(
        monthlyIncome: 500000,
        monthlyExpenses: 50000,
        currentBalance: 1000000,
        totalDebtEmi: 0,
        goals: [],
      );
      expect(extremeHighScore['score'], lessThanOrEqualTo(100));
      expect(extremeHighScore['score'], greaterThanOrEqualTo(0));

      final extremeLowScore = FinancialCalculatorService.calculateFinancialHealth(
        monthlyIncome: 10000,
        monthlyExpenses: 15000,
        currentBalance: 0,
        totalDebtEmi: 10000,
        goals: [],
      );
      expect(extremeLowScore['score'], lessThanOrEqualTo(100));
      expect(extremeLowScore['score'], greaterThanOrEqualTo(0));
    });
  });

  group('FinancialCalculatorService — Tax Calculator', () {
    test('income below basic exemption has zero tax', () {
      final res = FinancialCalculatorService.calculateTax(
        annualIncome: 250000,
        deduction80C: 0,
        healthInsurance80D: 0,
        standardDeduction: 50000,
        isNewRegime: true,
      );
      expect(res.estimatedTax, equals(0));
    });

    test('income above 15L attracts tax under old regime', () {
      final res = FinancialCalculatorService.calculateTax(
        annualIncome: 1500000,
        deduction80C: 150000,
        healthInsurance80D: 25000,
        standardDeduction: 50000,
        isNewRegime: false,
      );
      expect(res.estimatedTax, greaterThan(0));
    });

    test('new regime applies standard deduction and 87A rebate properly', () {
      final res = FinancialCalculatorService.calculateTax(
        annualIncome: 700000,
        deduction80C: 0,
        healthInsurance80D: 0,
        standardDeduction: 75000,
        isNewRegime: true,
      );
      expect(res.estimatedTax, equals(0)); // 7L or below taxable is 0 due to 87A
    });
  });

  group('Investment Accuracy & Calculations', () {
    test('InvestmentModel calculates accurate CAGR over multi-year holding', () {
      // Invested ₹1,00,000, current value ₹2,00,000 after 3 years (approx 26% CAGR)
      final purchaseDate = DateTime.now().subtract(const Duration(days: 365 * 3));
      final inv = InvestmentModel(
        id: 'inv1',
        name: 'Nifty Index Fund',
        assetType: 'Mutual Funds',
        investedAmount: 100000,
        currentValue: 200000,
        date: purchaseDate,
      );

      expect(inv.gainLoss, equals(100000));
      expect(inv.returnPercentage, equals(100.0)); // 100% absolute
      expect(inv.cagr, closeTo(26.0, 1.0)); // ~26% CAGR
    });

    test('Lump Sum projection compounds annually with future value > invested', () {
      final res = FinancialCalculatorService.calculateInvestmentProjections(
        monthlyInvestment: 100000, // 1 Lakh lump sum
        years: 5,
        isLumpSum: true,
      );

      final mod = res['moderate'] as Map<String, dynamic>;
      expect(res['totalInvested'], equals(100000));
      // At 12% annually for 5 years: 100000 * 1.12^5 = ~1,76,234
      expect(mod['futureValue'], closeTo(176234, 500));
      expect(mod['wealthGain'], closeTo(76234, 500));
    });

    test('Step-Up SIP accumulates significantly more wealth than flat SIP', () {
      final flatSip = FinancialCalculatorService.calculateInvestmentProjections(
        monthlyInvestment: 10000,
        years: 5,
        annualStepUpPercentage: 0.0,
      );

      final stepUpSip = FinancialCalculatorService.calculateInvestmentProjections(
        monthlyInvestment: 10000,
        years: 5,
        annualStepUpPercentage: 10.0, // 10% annual increase
      );

      final flatMod = flatSip['moderate'] as Map<String, dynamic>;
      final stepUpMod = stepUpSip['moderate'] as Map<String, dynamic>;

      expect(stepUpMod['futureValue'], greaterThan(flatMod['futureValue']));
      expect(stepUpSip['totalInvested'], greaterThan(flatSip['totalInvested']));
    });

    test('Inflation-adjusted real value is lower than nominal future value', () {
      final res = FinancialCalculatorService.calculateInvestmentProjections(
        monthlyInvestment: 5000,
        years: 10,
        inflationRate: 6.0,
      );

      final mod = res['moderate'] as Map<String, dynamic>;
      final nominalFv = mod['futureValue'] as double;
      final realFv = mod['realFutureValue'] as double;

      expect(realFv, lessThan(nominalFv));
      expect(realFv, greaterThan(0));
    });
  });
}
