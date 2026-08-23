import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../fund_details/domain/entities/fund_details.dart';
import '../../../fund_details/presentation/bloc/fund_details_bloc.dart';
import '../../../fund_details/presentation/bloc/fund_details_event.dart';
import '../../../fund_details/presentation/bloc/fund_details_state.dart';
import '../../../fund_details/presentation/bloc/option_chain/option_chain_bloc.dart';
import '../../../fund_details/presentation/bloc/option_chain/option_chain_state.dart';
import '../../../fund_details/presentation/widgets/fund_sections.dart';
import 'fund_details_skeleton.dart';

class FundContent extends StatelessWidget {
  const FundContent({
    required this.onBuy,
    required this.onSell,
    required this.onOpenFund,
    this.scrollController,
    this.showDragHandle = false,
    super.key,
  });
  final VoidCallback onBuy;
  final VoidCallback onSell;
  final void Function(String fundId, TradeExchange exchange) onOpenFund;
  final ScrollController? scrollController;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<FundDetailsBloc, FundDetailsState>(
        listenWhen: (previous, current) =>
            previous.messageVersion != current.messageVersion &&
                current.message != null ||
            previous.fund?.id != current.fund?.id ||
            previous.status != current.status,
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
          final fund = state.fund;
          if (fund != null && state.status == FundDetailsStatus.loaded) {
            final underlying = fund.instrumentType == FundInstrumentType.equity
                ? fund.symbol
                : fund.underlyingSymbol;
            if (underlying != null && underlying.isNotEmpty) {
              context.read<OptionChainBloc>().add(
                OptionChainStarted(
                  underlyingSymbol: underlying,
                  exchange: fund.exchange,
                  selectedStrikeMinor: fund.strikePrice == null
                      ? null
                      : (fund.strikePrice! * 100).round(),
                ),
              );
            }
          }
        },
        builder: (context, state) => CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  if (showDragHandle) ...[
                    Center(
                      child: Container(
                        width: AppSizes.buttonHeightSm,
                        height: AppRadius.xs,
                        decoration: BoxDecoration(
                          color: context.appColors.border,
                          borderRadius: AppRadius.pillBorderRadius,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
            switch (state.status) {
              FundDetailsStatus.initial || FundDetailsStatus.loading =>
                const SliverToBoxAdapter(child: FundDetailsSkeleton()),
              FundDetailsStatus.error => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: AppErrorState(
                    title: 'Unable to load fund details',
                    description: state.errorMessage ?? 'Please try again.',
                    onRetry: () => context.read<FundDetailsBloc>().add(
                      const FundDetailsRetryRequested(),
                    ),
                  ),
                ),
              ),
              FundDetailsStatus.loaded => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: FundLoadedSections(
                  state: state,
                  onBuy: onBuy,
                  onSell: onSell,
                  onOpenFund: onOpenFund,
                ),
              ),
            },
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          ],
        ),
      );
}
