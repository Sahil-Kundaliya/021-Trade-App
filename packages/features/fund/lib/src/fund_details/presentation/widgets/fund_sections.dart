import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core_data/core_data.dart';

import '../../domain/entities/fund_details.dart';
import '../bloc/fund_details_bloc.dart';
import '../bloc/fund_details_event.dart';
import '../bloc/fund_details_state.dart';
import 'chart/fund_live_chart.dart';
import 'derivatives/option_chain_section.dart';
import 'fund_format.dart';

class FundLoadedSections extends StatelessWidget {
  const FundLoadedSections({
    required this.state,
    required this.onBuy,
    required this.onSell,
    required this.onOpenFund,
    super.key,
  });
  final FundDetailsState state;
  final VoidCallback onBuy;
  final VoidCallback onSell;
  final void Function(String fundId, TradeExchange exchange) onOpenFund;

  @override
  Widget build(BuildContext context) {
    final fund = state.fund!;
    return SliverMainAxisGroup(
      slivers: [
        PinnedHeaderSliver(
          child: ColoredBox(
            key: const Key('fund-instrument-sticky-header'),
            color: context.appColors.surface,
            child: _FundContentWidth(
              child: _InstrumentHeader(fund: fund, state: state),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _FundContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                _TradeActions(onBuy: onBuy, onSell: onSell),
                const SizedBox(height: AppSpacing.lg),
                const _SectionCard(child: FundLiveChart()),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(child: _MarketStats(fund: fund)),
                if (fund.instrumentType == FundInstrumentType.future) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(child: FutureContractDetails(fund: fund)),
                ],
                if (fund.instrumentType == FundInstrumentType.option) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(child: OptionContractDetails(fund: fund)),
                ],
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(child: _MarketDepth(depth: fund.marketDepth)),
                if (fund.instrumentType == FundInstrumentType.equity) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    child: EquityDerivativesSection(
                      fund: fund,
                      onOpenFund: onOpenFund,
                    ),
                  ),
                ],
                if (fund.instrumentType != FundInstrumentType.equity) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    child: OptionChainSection(onOpenFund: onOpenFund),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(child: _Margin(details: fund.marginDetails)),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  child: _Collateral(details: fund.collateralDetails),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  child: _RecentActivity(activities: fund.recentActivity),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FundContentWidth extends StatelessWidget {
  const _FundContentWidth({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: child,
    ),
  );
}

class _InstrumentHeader extends StatelessWidget {
  const _InstrumentHeader({required this.fund, required this.state});
  final FundDetails fund;
  final FundDetailsState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTextStyles.marketSymbol,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      fund.companyName,
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
              const _FundLiveQuote(),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: state.isFundInWatchlist
                    ? 'Remove from Watchlist'
                    : 'Add to Watchlist',
                onPressed: state.isAddingToWatchlist
                    ? null
                    : () => context.read<FundDetailsBloc>().add(
                        state.isFundInWatchlist
                            ? const FundRemoveFromWatchlistRequested()
                            : const FundAddToWatchlistOpened(),
                      ),
                icon: Icon(
                  state.isFundInWatchlist
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _SmallTagChip(label: fund.exchange.code),
              _SmallTagChip(label: fund.category),
              for (final tag in fund.tags) _SmallTagChip(label: tag),
            ],
          ),
          if (state.isWatchlistPickerOpen) ...[
            const SizedBox(height: AppSpacing.md),
            const AppDivider(),
            const SizedBox(height: AppSpacing.md),
            _WatchlistPicker(state: state),
          ],
        ],
      ),
    );
  }
}

class _FundLiveQuote extends StatelessWidget {
  const _FundLiveQuote();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      FundDetailsBloc,
      FundDetailsState,
      MarketQuoteViewData?
    >(
      selector: (state) {
        final fund = state.fund;
        if (fund == null) return null;
        final tick = state.liveTick;
        return MarketQuoteViewData(
          ltp: tick?.ltp ?? fund.ltp,
          change: tick?.change ?? fund.change,
          changePercent: tick?.changePercent ?? fund.changePercent,
        );
      },
      builder: (context, quote) {
        if (quote == null) return const SizedBox.shrink();
        return MarketQuote(
          ltp: quote.ltp,
          change: quote.change,
          changePercent: quote.changePercent,
        );
      },
    );
  }
}

class _SmallTagChip extends StatelessWidget {
  const _SmallTagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: context.appColors.surfaceContainer,
      border: Border.all(color: context.appColors.borderSubtle),
      borderRadius: AppRadius.pillBorderRadius,
    ),
    child: Text(
      label,
      style: context.textTheme.labelSmall?.copyWith(
        color: context.appColors.textSecondary,
      ),
    ),
  );
}

class _WatchlistPicker extends StatelessWidget {
  const _WatchlistPicker({required this.state});
  final FundDetailsState state;

  @override
  Widget build(BuildContext context) => state.availableWatchlists.isEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('No watchlists available'),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.read<FundDetailsBloc>().add(
                const FundAddToWatchlistDismissed(),
              ),
              child: const Text('Close'),
            ),
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ADD TO WATCHLIST', style: context.appTextStyles.tableHeader),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: 'Choose Watchlist',
              initialValue: state.selectedWatchlistId,
              items: state.availableWatchlists
                  .map(
                    (watchlist) => DropdownMenuItem(
                      value: watchlist.id,
                      child: Text(
                        '${watchlist.name}${watchlist.containsFund(state.fund!.id) ? '  • Added' : ''}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: state.isAddingToWatchlist
                  ? null
                  : (id) {
                      if (id != null) {
                        context.read<FundDetailsBloc>().add(
                          FundWatchlistSelected(watchlistId: id),
                        );
                      }
                    },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: state.isAddingToWatchlist
                      ? null
                      : () => context.read<FundDetailsBloc>().add(
                          const FundAddToWatchlistDismissed(),
                        ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: _alreadySelected(state)
                      ? 'Already Added'
                      : state.isAddingToWatchlist
                      ? 'Adding…'
                      : 'Add',
                  onPressed:
                      state.isAddingToWatchlist || _alreadySelected(state)
                      ? null
                      : () => context.read<FundDetailsBloc>().add(
                          const FundAddToWatchlistRequested(),
                        ),
                ),
              ],
            ),
          ],
        );

  bool _alreadySelected(FundDetailsState state) =>
      state.availableWatchlists.any(
        (item) =>
            item.id == state.selectedWatchlistId &&
            item.containsFund(state.fund!.id),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(child: child);
}

/*
 * The watchlist picker intentionally remains inside the compact header card,
 * so opening it does not introduce a second disconnected section.
 */
class _TradeActions extends StatelessWidget {
  const _TradeActions({required this.onBuy, required this.onSell});
  final VoidCallback onBuy;
  final VoidCallback onSell;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.appColors.buy),
          onPressed: onBuy,
          child: const Text('BUY'),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.appColors.sell,
          ),
          onPressed: onSell,
          child: const Text('SELL'),
        ),
      ),
    ],
  );
}

class _MarketStats extends StatelessWidget {
  const _MarketStats({required this.fund});
  final FundDetails fund;
  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Open', _money(fund.open)),
      ('High', _money(fund.high)),
      ('Low', _money(fund.low)),
      ('Prev. Close', _money(fund.previousClose)),
      ('Volume', _compact(fund.volume)),
    ];
    return _TableRows(rows: rows);
  }
}

class _MarketDepth extends StatelessWidget {
  const _MarketDepth({required this.depth});
  final FundMarketDepth depth;
  @override
  Widget build(BuildContext context) {
    final count = math.max(depth.bids.length, depth.asks.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(title: 'MARKET DEPTH'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                'BUY / BID',
                style: context.appTextStyles.tableHeader.copyWith(
                  color: context.appColors.buy,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'SELL / ASK',
                textAlign: TextAlign.end,
                style: context.appTextStyles.tableHeader.copyWith(
                  color: context.appColors.sell,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _DepthRow(
          values: const ['Qty', 'Orders', 'Price', 'Price', 'Orders', 'Qty'],
          header: true,
        ),
        const AppDivider(),
        for (var i = 0; i < count; i++)
          _DepthRow(
            values: [
              i < depth.bids.length ? _integer(depth.bids[i].quantity) : '—',
              i < depth.bids.length ? '${depth.bids[i].orderCount}' : '—',
              i < depth.bids.length ? _money(depth.bids[i].price) : '—',
              i < depth.asks.length ? _money(depth.asks[i].price) : '—',
              i < depth.asks.length ? '${depth.asks[i].orderCount}' : '—',
              i < depth.asks.length ? _integer(depth.asks[i].quantity) : '—',
            ],
          ),
        const AppDivider(),
        const SizedBox(height: AppSpacing.md),
        _DepthImbalance(
          buyQuantity: depth.totalBidQuantity,
          sellQuantity: depth.totalAskQuantity,
        ),
      ],
    );
  }
}

class _DepthRow extends StatelessWidget {
  const _DepthRow({required this.values, this.header = false});
  final List<String> values;
  final bool header;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            flex: i == 2 || i == 3 ? 3 : 2,
            child: header
                ? Text(
                    values[i],
                    textAlign: i < 3 ? TextAlign.left : TextAlign.right,
                    maxLines: 1,
                    style: context.appTextStyles.tableHeader,
                  )
                : SensitiveValueText(
                    values[i],
                    type: i == 2 || i == 3
                        ? SensitiveValueType.currency
                        : SensitiveValueType.quantity,
                    textAlign: i < 3 ? TextAlign.left : TextAlign.right,
                    maxLines: 1,
                    style: context.appTextStyles.financialCaption,
                  ),
          ),
      ],
    ),
  );
}

class _DepthImbalance extends StatelessWidget {
  const _DepthImbalance({
    required this.buyQuantity,
    required this.sellQuantity,
  });

  final int buyQuantity;
  final int sellQuantity;

  @override
  Widget build(BuildContext context) {
    final total = buyQuantity + sellQuantity;
    final buyPercent = total == 0 ? 0.0 : buyQuantity / total * 100;
    final sellPercent = total == 0 ? 0.0 : sellQuantity / total * 100;
    final buyFraction = total == 0 ? 0.5 : buyQuantity / total;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buy',
                    style: context.appTextStyles.tableHeader.copyWith(
                      color: context.appColors.buy,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SensitiveValueText(
                    '${buyPercent.toStringAsFixed(0)}% (${_integer(buyQuantity)})',
                    maskedValue:
                        '${PrivacyMask.percentage} (${PrivacyMask.quantity})',
                    style: context.appTextStyles.tableValue,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sell',
                    style: context.appTextStyles.tableHeader.copyWith(
                      color: context.appColors.sell,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SensitiveValueText(
                    '${sellPercent.toStringAsFixed(0)}% (${_integer(sellQuantity)})',
                    maskedValue:
                        '${PrivacyMask.percentage} (${PrivacyMask.quantity})',
                    style: context.appTextStyles.tableValue,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.pillBorderRadius,
          child: SizedBox(
            height: AppSpacing.sm,
            child: LinearProgressIndicator(
              value: buyFraction,
              backgroundColor: context.appColors.sell,
              color: context.appColors.buy,
            ),
          ),
        ),
      ],
    );
  }
}

class _Margin extends StatelessWidget {
  const _Margin({required this.details});
  final FundMarginDetails details;
  @override
  Widget build(BuildContext context) => _DataSection(
    title: 'MARGIN',
    rows: [
      if (details.delivery != null) ('Delivery', _money(details.delivery)),
      if (details.intraday != null) ('Intraday', _money(details.intraday)),
      if (details.overnight != null) ('Overnight', _money(details.overnight)),
      if (details.span != null) ('SPAN', _money(details.span)),
      if (details.exposure != null) ('Exposure', _money(details.exposure)),
    ],
  );
}

class _Collateral extends StatelessWidget {
  const _Collateral({required this.details});
  final FundCollateralDetails details;
  @override
  Widget build(BuildContext context) => _DataSection(
    title: 'COLLATERAL',
    rows: [
      ('Eligible', details.isEligible ? 'Yes' : 'No'),
      ('Haircut', '${details.haircutPercent.toStringAsFixed(1)}%'),
      ('Eligible Value', _money(details.eligibleValue)),
      ('Post Haircut', _money(details.postHaircutValue)),
    ],
  );
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.activities});
  final List<FundActivity> activities;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeader(title: 'RECENT ACTIVITY'),
      const SizedBox(height: AppSpacing.sm),
      if (activities.isEmpty)
        Text(
          'No recent activity',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      for (final activity in activities) ...[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(activity.title),
          subtitle: Text(
            PrivacyModeScope.of(context) && activity.type != 'watchlist'
                ? 'Trading values hidden\n${_dateTime(activity.timestamp)}'
                : '${activity.description}\n${_dateTime(activity.timestamp)}',
          ),
          isThreeLine: true,
          leading: Icon(
            activity.type == 'watchlist'
                ? Icons.bookmark_outline
                : Icons.receipt_long_outlined,
          ),
        ),
        const AppDivider(),
      ],
    ],
  );
}

class _DataSection extends StatelessWidget {
  const _DataSection({required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeader(title: title),
      const SizedBox(height: AppSpacing.sm),
      _TableRows(rows: rows),
    ],
  );
}

class _TableRows extends StatelessWidget {
  const _TableRows({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var index = 0; index < rows.length; index++) ...[
        _ValueRow(label: rows[index].$1, value: rows[index].$2),
        if (index < rows.length - 1) const AppDivider(),
      ],
    ],
  );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: _structuralValueLabels.contains(label)
              ? Text(
                  value,
                  textAlign: TextAlign.end,
                  style: context.appTextStyles.tableValue,
                )
              : SensitiveValueText(
                  value,
                  textAlign: TextAlign.end,
                  style: context.appTextStyles.tableValue,
                  type: value.contains('%')
                      ? SensitiveValueType.percentage
                      : value.contains('₹') || value.contains('â‚¹')
                      ? SensitiveValueType.currency
                      : SensitiveValueType.number,
                ),
        ),
      ],
    ),
  );
}

const _structuralValueLabels = <String>{
  'Expiry',
  'Underlying',
  'Option Type',
  'Eligible',
};

String _money(num? value) => FundFormat.money(value);
String _integer(int? value) => FundFormat.integer(value);

String _compact(int value) => value >= 1000000
    ? '${(value / 1000000).toStringAsFixed(2)}M'
    : value >= 1000
    ? '${(value / 1000).toStringAsFixed(1)}K'
    : '$value';
String _date(DateTime? date) => date == null
    ? '—'
    : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String _dateTime(DateTime value) =>
    '${_date(value)} · ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
