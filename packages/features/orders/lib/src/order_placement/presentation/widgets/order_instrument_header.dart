import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order_instrument.dart';

class OrderInstrumentHeader extends StatelessWidget {
  const OrderInstrumentHeader({required this.instrument, super.key});
  final OrderInstrument instrument;

  @override
  Widget build(BuildContext context) {
    final positive = instrument.change >= 0;
    final changeColor = positive
        ? context.appColors.positive
        : context.appColors.negative;
    final sign = positive ? '+' : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                instrument.symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTextStyles.cardTitle,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                instrument.companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SensitiveValueText(
              _money(instrument.ltp),
              type: SensitiveValueType.currency,
              style: context.appTextStyles.priceMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            SensitiveValueText(
              '$sign${_money(instrument.change)} ($sign${instrument.changePercent.toStringAsFixed(2)}%)',
              maskedValue:
                  '${PrivacyMask.currency} (${PrivacyMask.percentage})',
              maxLines: 1,
              style: context.appTextStyles.percentageMedium.copyWith(
                color: changeColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _money(double value) => '₹${value.toStringAsFixed(2)}';
}
