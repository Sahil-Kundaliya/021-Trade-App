import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/market_preview_data.dart';
import '../../domain/entities/market_category.dart';
import '../../domain/entities/market_display_item.dart';
import '../../domain/entities/market_subcategory.dart';

class MarketScreener extends StatefulWidget {
  const MarketScreener({super.key});

  @override
  State<MarketScreener> createState() => _MarketScreenerState();
}

class _MarketScreenerState extends State<MarketScreener> {
  MarketCategory _selectedCategory = MarketCategory.equity;
  MarketSubcategory _selectedSubcategory = MarketSubcategory.topGainers;

  void _selectCategory(MarketCategory category) {
    if (category == _selectedCategory) return;
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = category.subcategories.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = MarketPreviewData.itemsFor(
      _selectedCategory,
      _selectedSubcategory,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Market Screener',
            subtitle: 'Explore market movers',
          ),
          const SizedBox(height: AppSpacing.lg),
          MarketCategorySelector(
            selectedCategory: _selectedCategory,
            onSelected: _selectCategory,
          ),
          const SizedBox(height: AppSpacing.md),
          MarketSubcategoryTabs(
            subcategories: _selectedCategory.subcategories,
            selectedSubcategory: _selectedSubcategory,
            onSelected: (subcategory) {
              setState(() => _selectedSubcategory = subcategory);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: AppDurations.fast,
            child: MarketList(
              key: ValueKey((_selectedCategory, _selectedSubcategory)),
              category: _selectedCategory,
              items: items,
            ),
          ),
        ],
      ),
    );
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
  const MarketList({required this.category, required this.items, super.key});

  final MarketCategory category;
  final List<MarketDisplayItem> items;

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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MarketListItem(category: category, item: visibleItems[index]),
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
        ? item.title
        : '${item.title} • Vol ${item.volume}';
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
    final movementColor = item.changePercent >= 0
        ? context.appColors.positive
        : context.appColors.negative;
    final percentage =
        '${item.changePercent >= 0 ? '+' : ''}'
        '${item.changePercent.toStringAsFixed(2)}%';

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.ltp,
                style: context.appTextStyles.priceSmall.copyWith(
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${item.change}  $percentage',
                style: context.appTextStyles.percentageSmall.copyWith(
                  color: movementColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
