class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final String icon;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.icon,
    required this.createdAt,
  });

  // ============================================================
  // JSON SERIALIZATION
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      limit: (json['limit'] as num?)?.toDouble() ?? 0.0,
      icon: json['icon']?.toString() ?? 'category',
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  BudgetModel copyWith({
    String? id,
    String? category,
    double? limit,
    String? icon,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}