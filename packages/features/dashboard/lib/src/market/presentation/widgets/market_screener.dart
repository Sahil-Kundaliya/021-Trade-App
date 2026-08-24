import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/market_category.dart';
import '../../domain/entities/market_display_item.dart';
import '../../domain/entities/market_instrument.dart';
import '../../domain/entities/market_subcategory.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_state.dart';

class MarketScreener extends StatelessWidget {
  const MarketScreener({
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.selectedExchange,
    required this.instruments,
    required this.onCategorySelected,
    required this.onSubcategorySelected,
    required this.onExchangeSelected,
    this.onItemTap,
    super.key,
  });

  final MarketCategory selectedCategory;
  final MarketSubcategory selectedSubcategory;
  final TradeExchange selectedExchange;
  final List<MarketInstrument> instruments;
  final ValueChanged<MarketCategory> onCategorySelected;
  final ValueChanged<MarketSubcategory> onSubcategorySelected;
  final ValueChanged<TradeExchange> onExchangeSelected;
  final ValueChanged<MarketDisplayItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final items = instruments.map(_toDisplayItem).toList(growable: false);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Market Screener',
            subtitle: 'Explore market movers',
            level: AppSectionHeaderLevel.card,
          ),
          const SizedBox(height: AppSpacing.lg),
          MarketCategorySelector(
            selectedCategory: selectedCategory,
            onSelected: onCategorySelected,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Exchange', style: context.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          if (selectedCategory == MarketCategory.equity)
            AppDropdown<TradeExchange>(
              key: const Key('market-screener-exchange'),
              initialValue: selectedExchange,
              items: TradeExchange.values
                  .map(
                    (exchange) => DropdownMenuItem(
                      value: exchange,
                      child: Text(exchange.code),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) onExchangeSelected(value);
              },
            )
          else
            InputDecorator(
              decoration: const InputDecoration(enabled: false),
              child: Text(TradeExchange.nse.code),
            ),
          const SizedBox(height: AppSpacing.md),
          MarketSubcategoryTabs(
            subcategories: selectedCategory.subcategories,
            selectedSubcategory: selectedSubcategory,
            onSelected: onSubcategorySelected,
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: context.motionDuration(AppMotion.short),
            switchInCurve: AppMotionCurves.enter,
            switchOutCurve: AppMotionCurves.exit,
            child: MarketList(
              key: ValueKey((
                selectedCategory,
                selectedSubcategory,
                selectedExchange,
              )),
              category: selectedCategory,
              items: items,
              onItemTap: onItemTap,
            ),
          ),
        ],
      ),
    );
  }

  MarketDisplayItem _toDisplayItem(MarketInstrument instrument) {
    final expiry = instrument.expiryDate;
    return MarketDisplayItem(
      id: instrument.id,
      marketKey: instrument.marketKey,
      symbol: instrument.category == MarketCategory.options
          ? instrument.underlyingSymbol ?? instrument.symbol
          : instrument.symbol,
      title: instrument.companyName,
      exchange: instrument.exchange,
      ltp: instrument.ltp,
      change: instrument.change,
      changePercent: instrument.changePercent,
      expiry: expiry == null
          ? null
          : '${expiry.day.toString().padLeft(2, '0')}/'
                '${expiry.month.toString().padLeft(2, '0')}/'
                '${expiry.year}',
      strike: instrument.strikePrice == null
          ? null
          : FinancialFormatter.price(instrument.strikePrice, symbol: false),
      optionType: instrument.optionType,
      volume: _compactVolume(instrument.volume),
    );
  }

  String _compactVolume(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class MarketCategorySelector extends StatelessWidget {
  const MarketCategorySelector({
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final MarketCategory selectedCategory;
  final ValueChanged<MarketCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in MarketCategory.values) ...[
            MarketCategoryChip(
              category: category,
              selected: category == selectedCategory,
              onSelected: () => onSelected(category),
            ),
            if (category != MarketCategory.values.last)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class MarketCategoryChip extends StatelessWidget {
  const MarketCategoryChip({
    required this.category,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final MarketCategory category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: category.label,
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class MarketSubcategoryTabs extends StatelessWidget {
  const MarketSubcategoryTabs({
    required this.subcategories,
    required this.selectedSubcategory,
    required this.onSelected,
    super.key,
  });

  final List<MarketSubcategory> subcategories;
  final MarketSubcategory selectedSubcategory;
  final ValueChanged<MarketSubcategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final subcategory in subcategories)
            _MarketTab(
              subcategory: subcategory,
              selected: subcategory == selectedSubcategory,
              onTap: () => onSelected(subcategory),
            ),
        ],
      ),
    );
  }
}

class _MarketTab extends StatelessWidget {
  const _MarketTab({
    required this.subcategory,
    required this.selected,
    required this.onTap,
  });

  final MarketSubcategory subcategory;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: AppRadius.smBorderRadius,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: selected
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.appColors.primary,
                      width: AppSpacing.xxs,
                    ),
                  ),
                )
              : null,
          child: Text(
            subcategory.label,
            style: context.textTheme.labelMedium?.copyWith(
              color: selected
                  ? context.appColors.primary
                  : context.appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class MarketList extends StatelessWidget {
  const MarketList({
    required this.category,
    required this.items,
    this.onItemTap,
    super.key,
  });

  final MarketCategory category;
  final List<MarketDisplayItem> items;
  final ValueChanged<MarketDisplayItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(5).toList(growable: false);
    if (visibleItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: Text(
            'No market data available',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        final item = visibleItems[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: onItemTap != null,
              child: InkWell(
                onTap: onItemTap == null ? null : () => onItemTap!(item),
                child: MarketListItem(
                  key: ValueKey(item.marketKey),
                  category: category,
                  item: item,
                ),
              ),
            ),
            if (index < visibleItems.length - 1) const AppDivider(),
          ],
        );
      },
    );
  }
}

class MarketListItem extends StatelessWidget {
  const MarketListItem({required this.category, required this.item, super.key});

  final MarketCategory category;
  final MarketDisplayItem item;

  @override
  Widget build(BuildContext context) {
    return switch (category) {
      MarketCategory.equity => EquityMarketListItem(item: item),
      MarketCategory.futures => FutureMarketListItem(item: item),
      MarketCategory.options => OptionMarketListItem(item: item),
    };
  }
}

class EquityMarketListItem extends StatelessWidget {
  const EquityMarketListItem({required this.item, super.key});

  final MarketDisplayItem item;

  @override
  Widget build(BuildContext context) {
    final secondary = item.volume == null
        ? '${item.exchange.code} • ${item.title}'
        : '${item.exchange.code} • ${item.title} • Vol ${item.volume}';
    return _MarketRow(primary: item.symbol, secondary: secondary, item: item);
  }
}

class FutureMarketListItem extends StatelessWidget {
  const FutureMarketListItem({required this.item, super.key});

  final MarketDisplayItem item;

  @override
  Widget build(BuildContext context) {
    final volume = item.volume == null ? '' : ' • Vol ${item.volume}';
    return _MarketRow(
      primary: item.symbol,
      secondary: '${item.title} • Expiry ${item.expiry}$volume',
      item: item,
    );
  }
}

class OptionMarketListItem extends StatelessWidget {
  const OptionMarketListItem({required this.item, super.key});

  final MarketDisplayItem item;

  @override
  Widget build(BuildContext context) {
    return _MarketRow(
      primary: '${item.symbol} ${item.strike} ${item.optionType}',
      secondary: '${item.title} • ${item.expiry}',
      item: item,
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({
    required this.primary,
    required this.secondary,
    required this.item,
  });

  final String primary;
  final String secondary;
  final MarketDisplayItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  secondary,
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
          _LiveMarketQuote(item: item),
        ],
      ),
    );
  }
}

class _LiveMarketQuote extends StatelessWidget {
  const _LiveMarketQuote({required this.item});

  final MarketDisplayItem item;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketBloc, MarketState, MarketQuoteViewData>(
      selector: (state) {
        final tick = state.livePrices[item.marketKey];
        return MarketQuoteViewData(
          ltp: tick?.ltp ?? item.ltp,
          change: tick?.change ?? item.change,
          changePercent: tick?.changePercent ?? item.changePercent,
        );
      },
      builder: (context, quote) => MarketQuote(
        ltp: quote.ltp,
        change: quote.change,
        changePercent: quote.changePercent,
      ),
    );
  }
}
