class ReceiptSuggestionService {
  static const List<String> standardCategories = [
    'Food & Dining',
    'Shopping',
    'Transport',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Travel',
    'Groceries',
    'Other',
  ];

  static const List<String> paymentMethods = [
    'UPI',
    'Cash',
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
    'Other',
  ];

  /// Intelligence mapping for merchants to categories
  static const Map<String, String> _merchantCategoryMap = {
    // Food & Dining
    'swiggy': 'Food & Dining',
    'zomato': 'Food & Dining',
    'starbucks': 'Food & Dining',
    'mcdonalds': 'Food & Dining',
    'mc donald': 'Food & Dining',
    'kfc': 'Food & Dining',
    'burger king': 'Food & Dining',
    'dominos': 'Food & Dining',
    'pizza hut': 'Food & Dining',
    'subway': 'Food & Dining',
    'haldiram': 'Food & Dining',
    'chai point': 'Food & Dining',
    'chaayos': 'Food & Dining',
    'cafe coffee day': 'Food & Dining',
    'barbeque nation': 'Food & Dining',
    'dunkin': 'Food & Dining',

    // Groceries
    'zepto': 'Groceries',
    'blinkit': 'Groceries',
    'instamart': 'Groceries',
    'bigbasket': 'Groceries',
    'bb daily': 'Groceries',
    'dmart': 'Groceries',
    'd-mart': 'Groceries',
    'reliance fresh': 'Groceries',
    'reliance smart': 'Groceries',
    'nature basket': 'Groceries',
    'spencer': 'Groceries',
    'more supermarket': 'Groceries',

    // Transport
    'uber': 'Transport',
    'ola': 'Transport',
    'rapido': 'Transport',
    'fastag': 'Transport',
    'irctc': 'Transport',
    'metro': 'Transport',
    'indian oil': 'Transport',
    'iocl': 'Transport',
    'bpcl': 'Transport',
    'hpcl': 'Transport',
    'petrol': 'Transport',
    'fuel': 'Transport',

    // Shopping
    'amazon': 'Shopping',
    'flipkart': 'Shopping',
    'myntra': 'Shopping',
    'ajio': 'Shopping',
    'zara': 'Shopping',
    'h&m': 'Shopping',
    'nykaa': 'Shopping',
    'meesho': 'Shopping',
    'croma': 'Shopping',
    'reliance digital': 'Shopping',
    'uniqlo': 'Shopping',
    'ikea': 'Shopping',
    'decathlon': 'Shopping',

    // Entertainment
    'netflix': 'Entertainment',
    'spotify': 'Entertainment',
    'prime video': 'Entertainment',
    'hotstar': 'Entertainment',
    'disney': 'Entertainment',
    'bookmyshow': 'Entertainment',
    'pvr': 'Entertainment',
    'inox': 'Entertainment',
    'cinepolis': 'Entertainment',
    'youtube': 'Entertainment',
    'playstation': 'Entertainment',
    'steam': 'Entertainment',

    // Health
    'apollo': 'Health',
    'pharmeasy': 'Health',
    '1mg': 'Health',
    'tata 1mg': 'Health',
    'netmeds': 'Health',
    'medplus': 'Health',
    'max healthcare': 'Health',
    'fortis': 'Health',
    'cult.fit': 'Health',
    'cultfit': 'Health',
    'practo': 'Health',

    // Bills & Utilities
    'bescom': 'Bills',
    'electricity': 'Bills',
    'water board': 'Bills',
    'airtel': 'Bills',
    'jio': 'Bills',
    'vi': 'Bills',
    'vodafone': 'Bills',
    'tata play': 'Bills',
    'piped gas': 'Bills',
    'adani gas': 'Bills',
    'tatapower': 'Bills',

    // Education
    'udemy': 'Education',
    'coursera': 'Education',
    'edx': 'Education',
    'byju': 'Education',
    'unacademy': 'Education',
    'bookstore': 'Education',
    'crossword': 'Education',

    // Travel
    'makemytrip': 'Travel',
    'goibibo': 'Travel',
    'cleartrip': 'Travel',
    'indigo': 'Travel',
    'air india': 'Travel',
    'agoda': 'Travel',
    'booking.com': 'Travel',
    'airbnb': 'Travel',
    'taj hotels': 'Travel',
    'marriott': 'Travel',
  };

  /// Suggests a category based on the merchant name or text.
  static String suggestCategory(String merchant) {
    final cleaned = merchant.toLowerCase().trim();
    if (cleaned.isEmpty) return 'Other';

    for (final entry in _merchantCategoryMap.entries) {
      if (cleaned.contains(entry.key)) {
        return entry.value;
      }
    }

    // Generic keywords fallback
    if (cleaned.contains('cafe') || cleaned.contains('restaurant') || cleaned.contains('baker') || cleaned.contains('kitchen') || cleaned.contains('bar') || cleaned.contains('food') || cleaned.contains('dining') || cleaned.contains('tea') || cleaned.contains('coffee')) {
      return 'Food & Dining';
    }
    if (cleaned.contains('mart') || cleaned.contains('market') || cleaned.contains('grocer') || cleaned.contains('vegetable') || cleaned.contains('fruit')) {
      return 'Groceries';
    }
    if (cleaned.contains('pharmacy') || cleaned.contains('hospital') || cleaned.contains('clinic') || cleaned.contains('diagnostic') || cleaned.contains('lab') || cleaned.contains('dent')) {
      return 'Health';
    }
    if (cleaned.contains('flight') || cleaned.contains('hotel') || cleaned.contains('resort') || cleaned.contains('tour') || cleaned.contains('trip')) {
      return 'Travel';
    }
    if (cleaned.contains('cinema') || cleaned.contains('theatre') || cleaned.contains('movie') || cleaned.contains('gaming') || cleaned.contains('game')) {
      return 'Entertainment';
    }
    if (cleaned.contains('school') || cleaned.contains('college') || cleaned.contains('university') || cleaned.contains('course') || cleaned.contains('tuition') || cleaned.contains('academy')) {
      return 'Education';
    }
    if (cleaned.contains('power') || cleaned.contains('utility') || cleaned.contains('broadband') || cleaned.contains('recharge') || cleaned.contains('bill')) {
      return 'Bills';
    }
    if (cleaned.contains('cabs') || cleaned.contains('auto') || cleaned.contains('ride') || cleaned.contains('toll') || cleaned.contains('parking')) {
      return 'Transport';
    }
    if (cleaned.contains('retail') || cleaned.contains('fashion') || cleaned.contains('apparel') || cleaned.contains('jewel') || cleaned.contains('shop')) {
      return 'Shopping';
    }

    return 'Other';
  }

  /// Suggests a payment method based on merchant or input text.
  static String suggestPaymentMethod(String text) {
    final cleaned = text.toLowerCase().trim();
    if (cleaned.contains('cash')) return 'Cash';
    if (cleaned.contains('credit card') || cleaned.contains('credit') || cleaned.contains('amex')) return 'Credit Card';
    if (cleaned.contains('debit card') || cleaned.contains('debit')) return 'Debit Card';
    if (cleaned.contains('netbanking') || cleaned.contains('transfer') || cleaned.contains('neft') || cleaned.contains('imps')) return 'Bank Transfer';
    return 'UPI'; // Default in India
  }

  /// Calculates the budget impact of this specific expense.
  static Map<String, dynamic> calculateBudgetImpact({
    required double expenseAmount,
    required double monthlyBudget,
    required double currentTotalExpenses,
  }) {
    final budget = monthlyBudget > 0 ? monthlyBudget : 25000.0;
    final newTotal = currentTotalExpenses + expenseAmount;
    final percentage = (newTotal / budget).clamp(0.0, 2.0);
    final isOverBudget = newTotal > budget;
    final remainingAfter = budget - newTotal;

    return {
      'monthlyBudget': budget,
      'newTotalExpense': newTotal,
      'percentage': percentage,
      'isOverBudget': isOverBudget,
      'remainingAfter': remainingAfter,
    };
  }

  /// Generates real contextual AI financial insights based on actual numbers.
  static Map<String, dynamic> generateInsight({
    required String merchant,
    required double amount,
    required String category,
    required double categoryMonthTotal,
    required double monthlyBudget,
    required double totalMonthlyExpenses,
  }) {
    final budget = monthlyBudget > 0 ? monthlyBudget : 25000.0;
    final impact = calculateBudgetImpact(
      expenseAmount: amount,
      monthlyBudget: budget,
      currentTotalExpenses: totalMonthlyExpenses,
    );

    final updatedCategoryTotal = categoryMonthTotal + amount;
    final categoryPercentageOfBudget = ((updatedCategoryTotal / budget) * 100).toStringAsFixed(0);

    String headline;
    String aiInsight;
    String recommendation;

    if (impact['isOverBudget'] as bool) {
      headline = 'Budget Target Exceeded';
      aiInsight =
          'This purchase brings your monthly expenses to ₹${updatedCategoryTotal.round()}, exceeding your target budget of ₹${budget.round()}.';
      recommendation =
          'Consider pausing discretionary spending in $category for the rest of this month to restore surplus cash flow.';
    } else if (category == 'Food & Dining' || category == 'Groceries') {
      headline = 'Dining & Provision Velocity';
      aiInsight =
          'This ₹${amount.round()} purchase for $merchant is safely within budget, but $category spending now accounts for $categoryPercentageOfBudget% of your total budget.';
      recommendation =
          'To maintain your monthly savings surplus, target keeping remaining $category spending under ₹${((budget * 0.25) / 4).round()} per week.';
    } else if (category == 'Shopping' || category == 'Entertainment') {
      headline = 'Discretionary Purchase Logged';
      aiInsight =
          'Your $category spending now sits at ₹${updatedCategoryTotal.round()} for this month. You still have ₹${(impact['remainingAfter'] as double).clamp(0.0, double.infinity).round()} in overall budget cushion.';
      recommendation =
          'Log purchases right away to avoid weekend lifestyle creep and maintain investment momentum.';
    } else {
      headline = 'Essential Outflow Recorded';
      aiInsight =
          'Payment of ₹${amount.round()} recorded under $category. Your overall budget remains healthy with ${(100 - ((impact['percentage'] as double) * 100)).clamp(0, 100).round()}% cushion remaining.';
      recommendation =
          'Keep recurring fixed obligations scheduled early in the month so your investable surplus is clear.';
    }

    return {
      'headline': headline,
      'insight': aiInsight,
      'recommendation': recommendation,
      'categoryMonthlyTotal': updatedCategoryTotal,
      'budgetImpact': impact,
    };
  }
}
