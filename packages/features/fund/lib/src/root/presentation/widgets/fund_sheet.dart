import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';

import 'fund_content.dart';

class FundSheet extends StatelessWidget {
  const FundSheet({required this.navigator, super.key});

  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: DraggableScrollableSheet(
          initialChildSize: 0.84,
          minChildSize: 0.52,
          maxChildSize: 1,
          expand: false,
          shouldCloseOnMinExtent: true,
          builder: (context, scrollController) {
            return Material(
              color: context.appColors.surface,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: SafeArea(
                top: false,
                child: FundContent(
                  scrollController: scrollController,
                  showDragHandle: true,
                  onClose: navigator.pop,
                  onBuy: _openOrders,
                  onSell: _openOrders,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openOrders() async {
    await navigator.pop();
    await navigator.openOrders();
  }
}
