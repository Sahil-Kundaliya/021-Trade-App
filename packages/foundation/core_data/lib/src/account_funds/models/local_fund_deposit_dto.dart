class LocalFundDepositDto {
  const LocalFundDepositDto({
    required this.id,
    required this.amount,
    required this.bankId,
    required this.createdAt,
  });

  factory LocalFundDepositDto.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    if (json['id'] is! String ||
        (json['id'] as String).trim().isEmpty ||
        json['amount'] is! num ||
        json['bankId'] is! String ||
        (json['bankId'] as String).trim().isEmpty ||
        createdAt == null) {
      throw const FormatException('Invalid fund deposit JSON.');
    }
    return LocalFundDepositDto(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      bankId: json['bankId'] as String,
      createdAt: createdAt,
    );
  }

  final String id;
  final double amount;
  final String bankId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'amount': amount,
    'bankId': bankId,
    'createdAt': createdAt.toIso8601String(),
  };
}
