import 'local_fund_deposit_dto.dart';

class AccountFundsStorageDto {
  const AccountFundsStorageDto({
    required this.availableBalance,
    required this.deposits,
  });

  factory AccountFundsStorageDto.empty() => const AccountFundsStorageDto(
    availableBalance: 0,
    deposits: <LocalFundDepositDto>[],
  );

  factory AccountFundsStorageDto.fromJson(Map<String, dynamic> json) {
    if (json['availableBalance'] is! num || json['deposits'] is! List) {
      throw const FormatException('Invalid account funds document.');
    }
    return AccountFundsStorageDto(
      availableBalance: (json['availableBalance'] as num).toDouble(),
      deposits: List<LocalFundDepositDto>.unmodifiable(
        (json['deposits'] as List).map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid fund deposit entry.');
          }
          return LocalFundDepositDto.fromJson(value);
        }),
      ),
    );
  }

  final double availableBalance;
  final List<LocalFundDepositDto> deposits;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'availableBalance': availableBalance,
    'deposits': deposits.map((deposit) => deposit.toJson()).toList(),
  };
}
