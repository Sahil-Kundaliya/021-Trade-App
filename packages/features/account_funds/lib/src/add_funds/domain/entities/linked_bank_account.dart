enum BankAccountType { savings, current }

class LinkedBankAccount {
  const LinkedBankAccount({
    required this.id,
    required this.bankName,
    required this.last4,
    required this.accountType,
    required this.isPrimary,
  });

  final String id;
  final String bankName;
  final String last4;
  final BankAccountType accountType;
  final bool isPrimary;

  String get maskedNumber => '•••• $last4';

  String get accountTypeLabel => switch (accountType) {
    BankAccountType.savings => 'Savings',
    BankAccountType.current => 'Current',
  };
}
