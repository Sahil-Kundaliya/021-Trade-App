import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../fund_details/presentation/bloc/fund_details_bloc.dart';
import '../../../fund_details/presentation/bloc/fund_details_event.dart';
import 'fund_content.dart';

class FundSheet extends StatelessWidget {
  const FundSheet({required this.fundId, required this.navigator, super.key});
  final String fundId;
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: DraggableScrollableSheet(
        initialChildSize: 0.84,
        minChildSize: 0.52,
        maxChildSize: 1,
        expand: false,
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) => Material(
          color: context.appColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: SafeArea(
            top: false,
            child: BlocProvider(
              create: (_) =>
                  GetIt.instance<FundDetailsBloc>()
                    ..add(FundDetailsStarted(fundId: fundId)),
              child: FundContent(
                scrollController: scrollController,
                showDragHandle: true,
                onClose: navigator.pop,
                onBuy: () => _openOrders(TradeSide.buy),
                onSell: () => _openOrders(TradeSide.sell),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _openOrders(TradeSide side) async {
    await navigator.pop();
    await navigator.openOrders(fundId: fundId, side: side);
  }
}
