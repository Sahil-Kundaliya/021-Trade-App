import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/fund_details.dart';
import '../../../domain/entities/option_chain.dart';
import '../../bloc/fund_details_bloc.dart';
import '../../bloc/fund_details_state.dart';
import '../../bloc/option_chain/option_chain_bloc.dart';
import '../../bloc/option_chain/option_chain_state.dart';
import '../fund_format.dart';

class FutureContractDetails extends StatelessWidget {
  const FutureContractDetails({required this.fund, super.key});
  final FundDetails fund;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FundDetailsBloc, FundDetailsState, double>(
      selector: (state) => state.liveTick?.ltp ?? fund.ltp,
      builder: (context, liveLtp) {
        return BlocBuilder<OptionChainBloc, OptionChainState>(
          buildWhen: (previous, current) =>
              previous.underlyingLtpMinor != current.underlyingLtpMinor,
          builder: (context, chain) {
            final spot = chain.underlyingLtp;
            final basis = spot == null ? null : liveLtp - spot;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTRACT DETAILS',
                  style: context.appTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                _kv(context, 'Underlying', fund.underlyingSymbol ?? '—'),
                _kv(
                  context,
                  'Spot',
                  FundFormat.money(spot),
                  sensitive: true,
                  animateLive: true,
                  liveDirection: _liveDirection(chain.underlyingTick),
                  liveUpdateId: chain.underlyingTick?.sequence,
                ),
                _kv(context, 'Expiry', FundFormat.date(fund.expiryDate)),
                _kv(context, 'Lot Size', FundFormat.integer(fund.lotSize)),
                _kv(
                  context,
                  'Open Interest',
                  fund.openInterest == null
                      ? '—'
                      : FundFormat.integer(fund.openInterest),
                  sensitive: true,
                ),
                if (basis != null)
                  _kv(
                    context,
                    'Basis',
                    FundFormat.signedMoney(basis),
                    sensitive: true,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class OptionContractDetails extends StatelessWidget {
  const OptionContractDetails({required this.fund, super.key});
  final FundDetails fund;

  @override
  Widget build(BuildContext context) {
    final side = fund.optionType?.toUpperCase() == 'PE'
        ? OptionSide.put
        : OptionSide.call;
    return BlocSelector<FundDetailsBloc, FundDetailsState, double>(
      selector: (state) => state.liveTick?.ltp ?? fund.ltp,
      builder: (context, liveLtp) {
        return BlocBuilder<OptionChainBloc, OptionChainState>(
          buildWhen: (previous, current) =>
              previous.underlyingLtpMinor != current.underlyingLtpMinor ||
              previous.atmStrikeMinor != current.atmStrikeMinor,
          builder: (context, chain) {
            final spotMinor = chain.underlyingLtpMinor;
            final strikeMinor = fund.strikePrice == null
                ? null
                : (fund.strikePrice! * 100).round();
            final intrinsicMinor = spotMinor == null || strikeMinor == null
                ? null
                : OptionChainAssembler.intrinsicMinor(
                    side: side,
                    strikeMinor: strikeMinor,
                    spotMinor: spotMinor,
                  );
            final timeMinor = intrinsicMinor == null
                ? null
                : OptionChainAssembler.timeValueMinor(
                    optionLtpMinor: (liveLtp * 100).round(),
                    intrinsicMinor: intrinsicMinor,
                  );
            final moneyness = spotMinor == null || strikeMinor == null
                ? null
                : OptionChainAssembler.moneyness(
                    side: side,
                    strikeMinor: strikeMinor,
                    spotMinor: spotMinor,
                    atmMinor: chain.atmStrikeMinor,
                  );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPTION DETAILS',
                  style: context.appTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                _kv(context, 'Underlying', fund.underlyingSymbol ?? '—'),
                _kv(
                  context,
                  'Spot',
                  FundFormat.money(chain.underlyingLtp),
                  sensitive: true,
                  animateLive: true,
                  liveDirection: _liveDirection(chain.underlyingTick),
                  liveUpdateId: chain.underlyingTick?.sequence,
                ),
                _kv(context, 'Type', side == OptionSide.call ? 'CALL' : 'PUT'),
                _kv(
                  context,
                  'Strike',
                  FundFormat.money(fund.strikePrice),
                  sensitive: true,
                ),
                _kv(context, 'Expiry', FundFormat.date(fund.expiryDate)),
                _kv(context, 'Lot Size', FundFormat.integer(fund.lotSize)),
                _kv(
                  context,
                  'Open Interest',
                  fund.openInterest == null
                      ? '—'
                      : FundFormat.integer(fund.openInterest),
                  sensitive: true,
                ),
                if (fund.impliedVolatility != null)
                  _kv(
                    context,
                    'Implied Volatility',
                    '${fund.impliedVolatility!.toStringAsFixed(1)}%',
                    sensitive: true,
                  ),
                if (moneyness != null)
                  _kv(context, 'Moneyness', switch (moneyness) {
                    OptionMoneyness.itm => 'ITM',
                    OptionMoneyness.atm => 'ATM',
                    OptionMoneyness.otm => 'OTM',
                  }),
                if (intrinsicMinor != null)
                  _kv(
                    context,
                    'Intrinsic',
                    FundFormat.money(intrinsicMinor / 100),
                    sensitive: true,
                  ),
                if (timeMinor != null)
                  _kv(
                    context,
                    'Time Value',
                    FundFormat.money(timeMinor / 100),
                    sensitive: true,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class EquityDerivativesSection extends StatelessWidget {
  const EquityDerivativesSection({
    required this.fund,
    required this.onOpenFund,
    super.key,
  });
  final FundDetails fund;
  final void Function(String fundId, TradeExchange exchange) onOpenFund;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OptionChainBloc, OptionChainState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.selectedExpiry != current.selectedExpiry ||
          previous.nearestFuture != current.nearestFuture ||
          previous.hasContracts != current.hasContracts ||
          previous.atmStrikeMinor != current.atmStrikeMinor,
      builder: (context, state) {
        if (state.status == OptionChainStatus.idle) {
          return const SizedBox.shrink();
        }
        if (state.status == OptionChainStatus.loading) {
          return const OptionChainSkeleton();
        }
        if (!state.hasContracts) return const SizedBox.shrink();
        return _CollapsedDerivatives(state: state, onOpenFund: onOpenFund);
      },
    );
  }
}

class _CollapsedDerivatives extends StatefulWidget {
  const _CollapsedDerivatives({required this.state, required this.onOpenFund});
  final OptionChainState state;
  final void Function(String fundId, TradeExchange exchange) onOpenFund;

  @override
  State<_CollapsedDerivatives> createState() => _CollapsedDerivativesState();
}

class _CollapsedDerivativesState extends State<_CollapsedDerivatives> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DERIVATIVES', style: context.appTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        if (state.nearestFuture != null)
          _kv(context, 'Nearest Future', state.nearestFuture!.symbol),
        _kv(context, 'Nearest Expiry', FundFormat.date(state.selectedExpiry)),
        if (state.atmStrikeMinor != null)
          _kv(
            context,
            'ATM',
            FundFormat.money(state.atmStrikeMinor! / 100),
            sensitive: true,
          ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: _expanded ? 'Hide Option Chain' : 'View Option Chain',
          onPressed: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.md),
          OptionChainTable(onOpenFund: widget.onOpenFund),
        ],
      ],
    );
  }
}

class OptionChainSection extends StatelessWidget {
  const OptionChainSection({required this.onOpenFund, super.key});
  final void Function(String fundId, TradeExchange exchange) onOpenFund;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OptionChainBloc, OptionChainState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.selectedExpiry != current.selectedExpiry ||
          previous.availableExpiries != current.availableExpiries ||
          previous.rows.length != current.rows.length,
      builder: (context, state) {
        if (state.status == OptionChainStatus.idle) {
          return const SizedBox.shrink();
        }
        if (state.status == OptionChainStatus.loading) {
          return const OptionChainSkeleton();
        }
        if (state.status == OptionChainStatus.error) {
          return AppErrorState(
            title: 'Unable to load option chain',
            onRetry: () => context.read<OptionChainBloc>().add(
              const OptionChainRetryRequested(),
            ),
            compact: true,
          );
        }
        if (!state.hasContracts) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OPTION CHAIN', style: context.appTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No option contracts available',
                style: context.appTextStyles.bodySecondary,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OPTION CHAIN', style: context.appTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Underlying ${state.underlyingSymbol}',
                        style: context.appTextStyles.bodySecondary,
                      ),
                      const _OptionChainSpot(),
                    ],
                  ),
                ),
                if (state.availableExpiries.length > 1)
                  SizedBox(
                    width: 168,
                    child: AppDropdown<DateTime>(
                      label: 'Expiry',
                      initialValue: state.selectedExpiry,
                      items: [
                        for (final expiry in state.availableExpiries)
                          DropdownMenuItem(
                            value: expiry,
                            child: Text(FundFormat.expiryChip(expiry)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<OptionChainBloc>().add(
                            OptionChainExpiryChanged(value),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            OptionChainTable(onOpenFund: onOpenFund),
          ],
        );
      },
    );
  }
}

class OptionChainTable extends StatelessWidget {
  const OptionChainTable({required this.onOpenFund, super.key});
  final void Function(String fundId, TradeExchange exchange) onOpenFund;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OptionChainBloc, OptionChainState>(
      buildWhen: (previous, current) =>
          !identical(previous.rows, current.rows) ||
          previous.exchange != current.exchange,
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 640,
            child: Column(
              children: [
                Row(
                  children: [
                    _head(context, 'CALL LTP', flex: 3),
                    _head(context, 'CHNG%', flex: 2),
                    _head(context, 'OI', flex: 2),
                    _head(context, 'STRIKE', flex: 3, align: TextAlign.center),
                    _head(context, 'OI', flex: 2, align: TextAlign.end),
                    _head(context, 'CHNG%', flex: 2, align: TextAlign.end),
                    _head(context, 'PUT LTP', flex: 3, align: TextAlign.end),
                  ],
                ),
                const AppDivider(),
                for (final row in state.rows)
                  _OptionChainRowView(
                    key: ValueKey(row.strikeMinor),
                    row: row,
                    exchange: state.exchange,
                    onOpenFund: onOpenFund,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _head(
    BuildContext context,
    String label, {
    required int flex,
    TextAlign align = TextAlign.start,
  }) => Expanded(
    flex: flex,
    child: Text(
      label,
      textAlign: align,
      style: context.appTextStyles.tableHeader,
    ),
  );
}

class _OptionChainRowView extends StatelessWidget {
  const _OptionChainRowView({
    required this.row,
    required this.exchange,
    required this.onOpenFund,
    super.key,
  });
  final OptionChainRow row;
  final TradeExchange exchange;
  final void Function(String fundId, TradeExchange exchange) onOpenFund;

  @override
  Widget build(BuildContext context) {
    final selected = row.isSelectedStrike;
    final highlight = row.isAtm || selected;
    return ColoredBox(
      color: highlight
          ? context.appColors.selectionContainer
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            _cell(context, row.call, exchange, onOpenFund, TextAlign.start, 3),
            _change(context, row.call, 2, TextAlign.start),
            _oi(context, row.call, 2, TextAlign.start),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  SensitiveValueText(
                    FundFormat.money(row.strike),
                    type: SensitiveValueType.currency,
                    textAlign: TextAlign.center,
                    style: context.appTextStyles.tableCell.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (row.isAtm)
                    Text('ATM', style: context.appTextStyles.statusLabel),
                ],
              ),
            ),
            _oi(context, row.put, 2, TextAlign.end),
            _change(context, row.put, 2, TextAlign.end),
            _cell(context, row.put, exchange, onOpenFund, TextAlign.end, 3),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    OptionContractViewData? contract,
    TradeExchange exchange,
    void Function(String fundId, TradeExchange exchange) onOpenFund,
    TextAlign align,
    int flex,
  ) {
    if (contract == null) {
      return Expanded(
        flex: flex,
        child: Text(
          '—',
          textAlign: align,
          style: context.appTextStyles.tableCell,
        ),
      );
    }
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => onOpenFund(contract.fundId, exchange),
        child:
            BlocSelector<
              OptionChainBloc,
              OptionChainState,
              MarketQuoteViewData
            >(
              selector: (state) {
                final tick = state.livePrices[contract.marketKey];
                return MarketQuoteViewData(
                  ltp: tick?.ltp ?? contract.ltp,
                  change: tick?.change ?? contract.change,
                  changePercent: tick?.changePercent ?? contract.changePercent,
                  liveDirection: _liveDirection(tick),
                  liveUpdateId: tick?.sequence,
                );
              },
              builder: (context, quote) => LiveValueFlash(
                direction: quote.liveDirection,
                updateId: quote.liveUpdateId,
                normalColor:
                    context.appTextStyles.tableCell.color ??
                    DefaultTextStyle.of(context).style.color ??
                    context.appColors.textPrimary,
                builder: (color) => SensitiveValueText(
                  FundFormat.money(quote.ltp),
                  type: SensitiveValueType.currency,
                  textAlign: align,
                  style: context.appTextStyles.tableCell.copyWith(color: color),
                ),
              ),
            ),
      ),
    );
  }

  Widget _change(
    BuildContext context,
    OptionContractViewData? contract,
    int flex,
    TextAlign align,
  ) {
    if (contract == null) {
      return Expanded(
        flex: flex,
        child: Text(
          '—',
          textAlign: align,
          style: context.appTextStyles.tableCell,
        ),
      );
    }
    return Expanded(
      flex: flex,
      child:
          BlocSelector<OptionChainBloc, OptionChainState, MarketQuoteViewData>(
            selector: (state) {
              final tick = state.livePrices[contract.marketKey];
              if (tick != null) {
                return MarketQuoteViewData(
                  ltp: tick.ltp,
                  change: tick.change,
                  changePercent: tick.changePercent,
                );
              }
              return MarketQuoteViewData(
                ltp: contract.ltp,
                change: contract.change,
                changePercent: contract.changePercent,
              );
            },
            builder: (context, quote) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: align == TextAlign.end
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: MarketPriceChange(
                change: quote.change,
                changePercent: quote.changePercent,
                textAlign: align,
                style: context.appTextStyles.tableCell,
              ),
            ),
          ),
    );
  }

  Widget _oi(
    BuildContext context,
    OptionContractViewData? contract,
    int flex,
    TextAlign align,
  ) {
    if (contract?.openInterest == null) {
      return Expanded(
        flex: flex,
        child: Text(
          '—',
          textAlign: align,
          style: context.appTextStyles.tableCell,
        ),
      );
    }
    return Expanded(
      flex: flex,
      child: SensitiveValueText(
        FundFormat.compact(contract!.openInterest!),
        type: SensitiveValueType.quantity,
        textAlign: align,
        style: context.appTextStyles.tableCell,
      ),
    );
  }
}

LiveValueDirection _liveDirection(LivePriceTick? tick) =>
    switch (tick?.direction) {
      LivePriceDirection.up => LiveValueDirection.up,
      LivePriceDirection.down => LiveValueDirection.down,
      LivePriceDirection.flat || null => LiveValueDirection.flat,
    };

class _OptionChainSpot extends StatelessWidget {
  const _OptionChainSpot();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OptionChainBloc, OptionChainState, MarketQuoteViewData>(
      selector: (state) => MarketQuoteViewData(
        ltp: state.underlyingLtp ?? 0,
        change: 0,
        changePercent: 0,
        liveDirection: _liveDirection(state.underlyingTick),
        liveUpdateId: state.underlyingTick?.sequence,
      ),
      builder: (context, quote) => LiveValueFlash(
        direction: quote.liveDirection,
        updateId: quote.liveUpdateId,
        normalColor:
            context.appTextStyles.financialCaption.color ??
            DefaultTextStyle.of(context).style.color ??
            context.appColors.textPrimary,
        builder: (color) => SensitiveValueText(
          'Spot ${FundFormat.money(quote.ltp)}',
          type: SensitiveValueType.currency,
          style: context.appTextStyles.financialCaption.copyWith(color: color),
        ),
      ),
    );
  }
}

class OptionChainSkeleton extends StatelessWidget {
  const OptionChainSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLine(width: 110, height: 14),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonBox(width: 168, height: 36),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonLine(widthFactor: 1, height: 12),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < 5; i++) ...[
          const SkeletonLine(widthFactor: 1, height: 18),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    ),
  );
}

Widget _kv(
  BuildContext context,
  String label,
  String value, {
  bool sensitive = false,
  bool animateLive = false,
  LiveValueDirection liveDirection = LiveValueDirection.flat,
  int? liveUpdateId,
}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
  child: Row(
    children: [
      Expanded(child: Text(label, style: context.appTextStyles.bodySecondary)),
      sensitive
          ? animateLive
                ? LiveValueFlash(
                    direction: liveDirection,
                    updateId: liveUpdateId,
                    normalColor:
                        context.appTextStyles.tableCell.color ??
                        DefaultTextStyle.of(context).style.color ??
                        context.appColors.textPrimary,
                    builder: (color) => SensitiveValueText(
                      value,
                      type: value.contains('%')
                          ? SensitiveValueType.percentage
                          : SensitiveValueType.currency,
                      style: context.appTextStyles.tableCell.copyWith(
                        color: color,
                      ),
                    ),
                  )
                : SensitiveValueText(
                    value,
                    type: value.contains('%')
                        ? SensitiveValueType.percentage
                        : SensitiveValueType.currency,
                    style: context.appTextStyles.tableCell,
                  )
          : Text(value, style: context.appTextStyles.tableCell),
    ],
  ),
);
