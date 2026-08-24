import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class DashboardMarketNews extends StatelessWidget {
  const DashboardMarketNews({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Top Market News',
          subtitle: 'Latest updates from the trading world',
          level: AppSectionHeaderLevel.card,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < _news.length; index++) ...[
          _MarketNewsItem(item: _news[index]),
          if (index < _news.length - 1) const AppDivider(),
        ],
      ],
    ),
  );
}

class _MarketNewsItem extends StatelessWidget {
  const _MarketNewsItem({required this.item});

  final _MarketNewsData item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSizes.touchTarget,
          height: AppSizes.touchTarget,
          decoration: BoxDecoration(
            color: context.appColors.primaryContainer,
            borderRadius: AppRadius.mdBorderRadius,
          ),
          alignment: Alignment.center,
          child: Icon(
            item.icon,
            size: AppSizes.iconSm,
            color: context.appColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.dateTime,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.appColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MarketNewsData {
  const _MarketNewsData({
    required this.dateTime,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String dateTime;
  final String title;
  final String description;
  final IconData icon;
}

const _news = [
  _MarketNewsData(
    dateTime: '24 Aug 2026 • 03:35 PM',
    title: 'Benchmark indices end higher as banks lead gains',
    description:
        'Domestic indices closed in the green after financial and banking stocks attracted steady buying through the afternoon session.',
    icon: Icons.show_chart_rounded,
  ),
  _MarketNewsData(
    dateTime: '24 Aug 2026 • 02:10 PM',
    title: 'Rupee strengthens against the US dollar',
    description:
        'The local currency gained as softer crude prices and foreign fund inflows supported sentiment in the currency market.',
    icon: Icons.currency_rupee_rounded,
  ),
  _MarketNewsData(
    dateTime: '24 Aug 2026 • 12:45 PM',
    title: 'IT shares rise on renewed global demand outlook',
    description:
        'Technology counters traded firm as investors assessed improving enterprise spending and stronger demand expectations.',
    icon: Icons.memory_rounded,
  ),
  _MarketNewsData(
    dateTime: '24 Aug 2026 • 10:20 AM',
    title: 'Metal stocks gain as commodity prices recover',
    description:
        'Metal producers moved higher in early trade after base-metal prices recovered across major international exchanges.',
    icon: Icons.factory_outlined,
  ),
];
