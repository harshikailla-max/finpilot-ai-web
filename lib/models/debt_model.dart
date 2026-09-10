import 'dart:math' as math;

class DebtModel {
  final String id;
  final String loanName;
  final double principal;
  final double interestRate; // annual percentage, e.g. 9.5%
  final int tenureMonths;
  final double emi;
  final double outstandingBalance;
  final DateTime startDate;

  DebtModel({
    required this.id,
    required this.loanName,
    required this.principal,
    required this.interestRate,
    required this.tenureMonths,
    double? emi,
    double? outstandingBalance,
    DateTime? startDate,
  })  : emi = emi ?? calculateEmi(principal, interestRate, tenureMonths),
        outstandingBalance = outstandingBalance ?? principal,
        startDate = startDate ?? DateTime.now();

  static double calculateEmi(double principal, double annualRate, int months) {
    if (annualRate <= 0 || months <= 0) return months > 0 ? principal / months : 0.0;
    final r = (annualRate / 12) / 100;
    final emi = (principal * r * math.pow(1 + r, months)) / (math.pow(1 + r, months) - 1);
    return emi.isFinite ? emi : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loanName': loanName,
      'principal': principal,
      'interestRate': interestRate,
      'tenureMonths': tenureMonths,
      'emi': emi,
      'outstandingBalance': outstandingBalance,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id']?.toString() ?? '',
      loanName: map['loanName']?.toString() ?? 'Loan',
      principal: (map['principal'] as num?)?.toDouble() ?? 0.0,
      interestRate: (map['interestRate'] as num?)?.toDouble() ?? 0.0,
      tenureMonths: (map['tenureMonths'] as num?)?.toInt() ?? 12,
      emi: (map['emi'] as num?)?.toDouble(),
      outstandingBalance: (map['outstandingBalance'] as num?)?.toDouble(),
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
