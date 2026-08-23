import 'package:flutter/material.dart';

import 'privacy_mode_scope.dart';

enum SensitiveValueType { currency, percentage, quantity, number }

abstract final class PrivacyMask {
  static const currency = '₹••••••';
  static const percentage = '••••%';
  static const quantity = '••••';
  static const number = '••••';

  static String value(SensitiveValueType type, {String? suffix}) {
    final masked = switch (type) {
      SensitiveValueType.currency => currency,
      SensitiveValueType.percentage => percentage,
      SensitiveValueType.quantity => quantity,
      SensitiveValueType.number => number,
    };
    return suffix == null ? masked : '$masked$suffix';
  }
}

class SensitiveValueText extends StatelessWidget {
  const SensitiveValueText(
    this.value, {
    this.type = SensitiveValueType.number,
    this.maskedValue,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    super.key,
  });

  final String value;
  final SensitiveValueType type;
  final String? maskedValue;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    final masked = PrivacyModeScope.of(context);
    return Text(
      masked ? maskedValue ?? PrivacyMask.value(type) : value,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
