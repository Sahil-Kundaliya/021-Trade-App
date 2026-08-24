import 'package:flutter/services.dart';

final class AccountFundsAmountFormatter extends TextInputFormatter {
  const AccountFundsAmountFormatter();

  static final _allowed = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty || _allowed.hasMatch(text)) return newValue;
    return oldValue;
  }
}
