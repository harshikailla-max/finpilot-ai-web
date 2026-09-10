enum GoalCategory {
  emergency,
  travel,
  vehicle,
  home,
  education,
  investment,
  gadget,
  wedding,
  purchase,
  retirement,
  other,
}

enum GoalPriority {
  low,
  medium,
  high,
}

class FinancialGoal {
  final String id;
  final String title;
  final String? description;

  final double targetAmount;
  final double currentAmount;

  final GoalCategory category;
  final GoalPriority priority;

  final DateTime createdDate;
  final DateTime? targetDate;

  final bool isCompleted;

  FinancialGoal({
    required this.id,
    required this.title,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.category,
    required this.priority,
    required this.createdDate,
    this.targetDate,
    this.isCompleted = false,
  });

  // ============================================================
  // PROGRESS
  // ============================================================

  double get savedAmount => currentAmount;

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;

    return (currentAmount / targetAmount)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  // ============================================================
  // REMAINING AMOUNT
  // ============================================================

  double get remainingAmount {
    final remaining = targetAmount - currentAmount;

    return remaining > 0 ? remaining : 0.0;
  }

  // ============================================================
  // DAYS REMAINING
  // ============================================================

  int? get daysRemaining {
    if (targetDate == null) return null;

    final today = DateTime.now();

    final difference = targetDate!
        .difference(
          DateTime(
            today.year,
            today.month,
            today.day,
          ),
        )
        .inDays;

    return difference < 0 ? 0 : difference;
  }

  // ============================================================
  // CATEGORY NAME
  // ============================================================

  String get categoryName {
    switch (category) {
      case GoalCategory.emergency:
        return 'Emergency Fund';

      case GoalCategory.travel:
        return 'Travel';

      case GoalCategory.vehicle:
        return 'Vehicle';

      case GoalCategory.home:
        return 'Home';

      case GoalCategory.education:
        return 'Education';

      case GoalCategory.investment:
        return 'Investment';

      case GoalCategory.gadget:
        return 'Gadget';

      case GoalCategory.wedding:
        return 'Wedding';

      case GoalCategory.purchase:
        return 'Purchase';

      case GoalCategory.retirement:
        return 'Retirement';

      case GoalCategory.other:
        return 'Other';
    }
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  FinancialGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    GoalCategory? category,
    GoalPriority? priority,
    DateTime? createdDate,
    DateTime? targetDate,
    bool? isCompleted,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdDate: createdDate ?? this.createdDate,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // ============================================================
  // JSON SERIALIZATION
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'category': category.name,
      'priority': priority.name,
      'createdDate': createdDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? 'Goal',
      description: map['description']?.toString(),
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      category: GoalCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => GoalCategory.other,
      ),
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => GoalPriority.medium,
      ),
      createdDate: map['createdDate'] != null
          ? DateTime.tryParse(map['createdDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      targetDate: map['targetDate'] != null
          ? DateTime.tryParse(map['targetDate'].toString())
          : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory FinancialGoal.fromJson(Map<String, dynamic> json) =>
      FinancialGoal.fromMap(json);
}