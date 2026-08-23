import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/order_enums.dart';

class BuySellSwitch extends StatelessWidget {
  const BuySellSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final OrderSide value;
  final ValueChanged<OrderSide> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: OrderSide.values.map((side) {
      final selected = value == side;
      final buy = side == OrderSide.buy;
      final color = buy ? context.appColors.buy : context.appColors.sell;
      final container = buy
          ? context.appColors.buyContainer
          : context.appColors.sellContainer;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: buy ? AppSpacing.sm : AppSpacing.none,
          ),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: selected ? color : container,
              foregroundColor: selected ? context.appColors.textInverse : color,
            ),
            onPressed: () => onChanged(side),
            child: Text(side.name.toUpperCase()),
          ),
        ),
      );
    }).toList(),
  );
}
