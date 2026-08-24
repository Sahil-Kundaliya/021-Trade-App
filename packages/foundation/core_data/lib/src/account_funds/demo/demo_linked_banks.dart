import '../models/linked_bank_account_dto.dart';

abstract final class DemoLinkedBanks {
  static const hdfc = LinkedBankAccountDto(
    id: 'bank_hdfc_demo',
    bankName: 'HDFC Bank',
    last4: '4321',
    accountType: 'savings',
    isPrimary: true,
  );

  static const icici = LinkedBankAccountDto(
    id: 'bank_icici_demo',
    bankName: 'ICICI Bank',
    last4: '9854',
    accountType: 'savings',
    isPrimary: false,
  );

  static const axis = LinkedBankAccountDto(
    id: 'bank_axis_demo',
    bankName: 'Axis Bank',
    last4: '2248',
    accountType: 'savings',
    isPrimary: false,
  );

  static const List<LinkedBankAccountDto> all = <LinkedBankAccountDto>[
    hdfc,
    icici,
    axis,
  ];
}
