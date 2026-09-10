import 'dart:math' as math;

class InvestmentModel {
  final String id;
  final String name;
  final String assetType; // 'Stocks / Equity', 'Mutual Funds', 'Fixed Deposit', 'Gold', 'Crypto', 'Real Estate', 'PPF / EPF', etc.
  final double investedAmount;
  final double currentValue;
  final DateTime date;
  final double? quantity;
  final double? buyPrice;
  final double? currentPrice;
  final String? notes;

  InvestmentModel({
    required this.id,
    required this.name,
    required this.assetType,
    required this.investedAmount,
    required this.currentValue,
    required this.date,
    this.quantity,
    this.buyPrice,
    this.currentPrice,
    this.notes,
  });

  double get gainLoss => currentValue - investedAmount;

  double get returnPercentage =>
      investedAmount > 0 ? (gainLoss / investedAmount) * 100 : 0.0;

  bool get isProfitable => gainLoss >= 0;

  int get holdingDays => DateTime.now().difference(date).inDays;

  /// Compound Annual Growth Rate (CAGR) / Annualized Return
  double get cagr {
    final days = holdingDays;
    if (days < 30 || investedAmount <= 0 || currentValue <= 0) {
      return returnPercentage; // fallback to absolute return for very short horizon or non-positive
    }
    final years = days / 365.25;
    try {
      final rate = math.pow(currentValue / investedAmount, 1.0 / years) - 1.0;
      return (rate * 100).toDouble();
    } catch (_) {
      return returnPercentage;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'assetType': assetType,
      'investedAmount': investedAmount,
      'currentValue': currentValue,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'buyPrice': buyPrice,
      'currentPrice': currentPrice,
      'notes': notes,
    };
  }

  factory InvestmentModel.fromMap(Map<String, dynamic> map) {
    return InvestmentModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Investment',
      assetType: map['assetType']?.toString() ?? 'Mutual Funds',
      investedAmount: (map['investedAmount'] as num?)?.toDouble() ?? 0.0,
      currentValue: (map['currentValue'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      quantity: (map['quantity'] as num?)?.toDouble(),
      buyPrice: (map['buyPrice'] as num?)?.toDouble(),
      currentPrice: (map['currentPrice'] as num?)?.toDouble(),
      notes: map['notes']?.toString(),
    );
  }

  InvestmentModel copyWith({
    String? id,
    String? name,
    String? assetType,
    double? investedAmount,
    double? currentValue,
    DateTime? date,
    double? quantity,
    double? buyPrice,
    double? currentPrice,
    String? notes,
  }) {
    return InvestmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assetType: assetType ?? this.assetType,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      notes: notes ?? this.notes,
    );
  }
}
