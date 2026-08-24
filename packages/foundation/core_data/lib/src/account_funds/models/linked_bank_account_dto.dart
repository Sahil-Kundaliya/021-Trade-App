class LinkedBankAccountDto {
  const LinkedBankAccountDto({
    required this.id,
    required this.bankName,
    required this.last4,
    required this.accountType,
    required this.isPrimary,
  });

  final String id;
  final String bankName;
  final String last4;
  final String accountType;
  final bool isPrimary;
}
