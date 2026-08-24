class FundDeposit {
  const FundDeposit({
    required this.id,
    required this.amount,
    required this.bankId,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String bankId;
  final DateTime createdAt;
}
