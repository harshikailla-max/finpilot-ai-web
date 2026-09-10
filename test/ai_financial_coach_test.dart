import 'package:flutter_test/flutter_test.dart';
import 'package:finpilot_ai/models/finance_transaction.dart';
import 'package:finpilot_ai/services/ai_financial_coach_service.dart';

void main() {
  setUp(() {
    AiFinancialCoachService.resetMemory();
  });

  group('AiFinancialCoachService — Purchase Affordability', () {
    test('marks purchase as SAFE when balance exceeds price + 3-month emergency reserve', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Can I afford a ₹30,000 phone?',
        currentBalance: 200000,
        monthlyIncome: 80000,
        monthlyExpenses: 30000, // 3-month reserve = 90k. Total needed = 120k. Balance = 200k.
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 85,
      );

      expect(response.text, contains('SAFE TO PURCHASE'));
      expect(response.text, contains('SHORT ANSWER'));
      expect(response.text, contains('YOUR NUMBERS'));
      expect(response.text, contains('ACTION PLAN'));
      expect(response.actionTypes, contains('open_goal'));
    });

    test('marks purchase as CAUTION when balance covers price but dips into emergency reserve', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Can I afford a ₹50,000 laptop?',
        currentBalance: 80000,
        monthlyIncome: 60000,
        monthlyExpenses: 30000, // 3-month reserve = 90k. Price = 50k. Balance = 80k.
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 70,
      );

      expect(response.text, contains('CAUTION'));
      expect(response.text, contains('RECOMMENDATION'));
    });

    test('marks purchase as NOT RECOMMENDED when balance is below purchase price', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Can I afford a ₹1,00,000 TV?',
        currentBalance: 40000,
        monthlyIncome: 50000,
        monthlyExpenses: 35000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 60,
      );

      expect(response.text, contains('NOT RECOMMENDED TODAY'));
      expect(response.text, contains('funding deficit'));
    });
  });

  group('AiFinancialCoachService — Car & Big Milestone Blueprint', () {
    test('calculates car down payment, EMI, and feasibility', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Can I afford a car next year?',
        currentBalance: 250000,
        monthlyIncome: 100000,
        monthlyExpenses: 40000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 80,
      );

      expect(response.text, contains('CAR AFFORDABILITY BLUEPRINT'));
      expect(response.text, contains('20% Down Payment'));
      expect(response.text, contains('Estimated Monthly EMI'));
      expect(response.actionTypes, contains('open_car_calc'));
    });
  });

  group('AiFinancialCoachService — Emergency Fund & Financial Health', () {
    test('calculates 6-month emergency reserve requirement and deficit', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'How much money do I need for my emergency fund?',
        currentBalance: 60000,
        monthlyIncome: 70000,
        monthlyExpenses: 30000, // 6-month need = 180,000
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 75,
      );

      expect(response.text, contains('EMERGENCY FUND BLUEPRINT'));
      expect(response.text, contains('180,000'));
      expect(response.actionTypes, contains('open_investment'));
    });

    test('evaluates financial health score diagnostic', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Why did my financial health score decrease?',
        currentBalance: 50000,
        monthlyIncome: 60000,
        monthlyExpenses: 40000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 68,
      );

      expect(response.text, contains('FINANCIAL HEALTH DIAGNOSTIC'));
      expect(response.text, contains('68 / 100'));
    });
  });

  group('AiFinancialCoachService — Investment Strategy & Compounding', () {
    test('recommends 3-tier asset allocation for investment query', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Where should I invest my money?',
        currentBalance: 150000,
        monthlyIncome: 90000,
        monthlyExpenses: 50000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 82,
      );

      expect(response.text, contains('INTELLIGENT INVESTMENT STRATEGY'));
      expect(response.text, contains('Tier 1'));
      expect(response.text, contains('Tier 2'));
      expect(response.text, contains('Tier 3'));
      expect(response.actionTypes, contains('open_investment'));
    });

    test('projects 5-year future value compounding accurately', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'What happens if I save ₹10,000 every month?',
        currentBalance: 100000,
        monthlyIncome: 80000,
        monthlyExpenses: 40000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 80,
      );

      expect(response.text, contains('5-YEAR COMPOUNDING PROJECTION'));
      expect(response.text, contains('Projected Maturity Value'));
      expect(response.actionTypes, contains('future_sim'));
    });

    test('recommends retirement corpus calculation (25x annual expenses)', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'How much should I invest for retirement?',
        currentBalance: 200000,
        monthlyIncome: 100000,
        monthlyExpenses: 40000, // 480k/yr * 25 = 1.2 Crore
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 85,
      );

      expect(response.text, contains('RETIREMENT FREEDOM BLUEPRINT'));
      expect(response.text, contains('Crore'));
    });
  });

  group('AiFinancialCoachService — Spending, Budget & Debt Strategy', () {
    test('identifies top category in spending audit', () {
      final transactions = [
        FinanceTransaction(
          id: '1',
          title: 'Dining Out',
          amount: 15000,
          type: 'expense',
          category: 'Food & Dining',
          date: DateTime.now(),
        ),
        FinanceTransaction(
          id: '2',
          title: 'Groceries',
          amount: 5000,
          type: 'expense',
          category: 'Food & Dining',
          date: DateTime.now(),
        ),
        FinanceTransaction(
          id: '3',
          title: 'Clothes',
          amount: 6000,
          type: 'expense',
          category: 'Shopping',
          date: DateTime.now(),
        ),
      ];

      final response = AiFinancialCoachService.processQuery(
        question: 'Where is most of my money going?',
        currentBalance: 100000,
        monthlyIncome: 80000,
        monthlyExpenses: 26000,
        transactions: transactions,
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 78,
      );

      expect(response.text, contains('SPENDING INTELLIGENCE AUDIT'));
      expect(response.text, contains('Food & Dining'));
    });

    test('constructs 50/30/20 budget breakdown', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Create a monthly budget for me',
        currentBalance: 100000,
        monthlyIncome: 80000,
        monthlyExpenses: 40000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 80,
      );

      expect(response.text, contains('PERSONALIZED 50/30/20 BUDGET'));
      expect(response.text, contains('Needs'));
      expect(response.text, contains('Wants'));
      expect(response.text, contains('Savings'));
      expect(response.actionTypes, contains('create_budget'));
    });

    test('recommends Avalanche method for high-interest debt', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Should I pay my debt first or invest?',
        currentBalance: 60000,
        monthlyIncome: 75000,
        monthlyExpenses: 45000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 72,
      );

      expect(response.text, contains('DEBT VS. INVESTING STRATEGY'));
      expect(response.text, contains('Avalanche method'));
    });
  });

  group('AiFinancialCoachService — Conversation Context & Session Memory', () {
    test('maintains context across sequential follow-up queries', () {
      // First turn: User asks about car
      AiFinancialCoachService.processQuery(
        question: 'I want to buy a car for ₹8 lakh',
        currentBalance: 200000,
        monthlyIncome: 90000,
        monthlyExpenses: 40000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 80,
      );

      // Second turn: User asks follow-up: "Can I do it faster?"
      final followUp = AiFinancialCoachService.processQuery(
        question: 'Can I do it faster?',
        currentBalance: 200000,
        monthlyIncome: 90000,
        monthlyExpenses: 40000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 80,
      );

      expect(followUp.text, contains('FOLLOW-UP INSIGHT (CAR)'));
      expect(followUp.text, contains('Accelerated Allocation'));
    });
  });

  group('AiFinancialCoachService — CA-Style Tax Guidance & Cash Flow', () {
    test('provides Indian CA-style advice on Section 80C and old vs new regime', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'Should I choose old or new tax regime and how does 80C work?',
        currentBalance: 150000,
        monthlyIncome: 85000,
        monthlyExpenses: 40000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 84,
      );

      expect(response.text, contains('CA-STYLE TAX INTELLIGENCE & PLANNING'));
      expect(response.text, contains('Standard Deduction (New Regime): ₹75,000'));
      expect(response.text, contains('80C'));
      expect(response.actionTypes, contains('open_tax'));
    });

    test('generates multi-horizon cash flow forecast', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'What is my cash flow forecast for the next year?',
        currentBalance: 100000,
        monthlyIncome: 70000,
        monthlyExpenses: 35000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 80,
      );

      expect(response.text, contains('CASH FLOW & MULTI-HORIZON FORECAST'));
      expect(response.text, contains('1-Year Net Wealth Generation'));
      expect(response.actionTypes, contains('future_sim'));
    });

    test('identifies subscriptions and provides audit action', () {
      final response = AiFinancialCoachService.processQuery(
        question: 'How much am I spending on recurring subscriptions like Netflix?',
        currentBalance: 50000,
        monthlyIncome: 60000,
        monthlyExpenses: 30000,
        transactions: [],
        goals: [],
        budgets: [],
        investments: [],
        financialHealthScore: 75,
      );

      expect(response.text, contains('RECURRING CHARGES & SUBSCRIPTION AUDIT'));
      expect(response.actionTypes, contains('review_subs'));
    });
  });
}
