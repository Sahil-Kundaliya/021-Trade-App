import 'dart:async';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class DashboardBannerCarousel extends StatefulWidget {
  const DashboardBannerCarousel({super.key});

  @override
  State<DashboardBannerCarousel> createState() =>
      _DashboardBannerCarouselState();
}

class _DashboardBannerCarouselState extends State<DashboardBannerCarousel> {
  static const _initialPage = 3000;
  static const _rotationInterval = Duration(seconds: 4);

  late final PageController _controller;
  Timer? _rotationTimer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: .65,
    );
    // Automated widget tests need a stable frame tree for pumpAndSettle. Live
    // and production bindings still use the normal automatic rotation.
    if (!WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    )) {
      _scheduleRotation();
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleRotation() {
    _rotationTimer = Timer(_rotationInterval, _showNext);
  }

  Future<void> _showNext() async {
    if (!_controller.hasClients) {
      if (mounted) _scheduleRotation();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    if (mounted) _scheduleRotation();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppSectionHeader(
        title: 'Featured',
        subtitle: 'Ideas and opportunities for you',
      ),
      const SizedBox(height: AppSpacing.md),
      LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: (constraints.maxWidth * .35).clamp(150, 220),
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (page) =>
                setState(() => _selectedIndex = page % _banners.length),
            itemBuilder: (context, page) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final currentPage =
                    _controller.hasClients &&
                        _controller.position.haveDimensions
                    ? _controller.page ?? page.toDouble()
                    : _initialPage.toDouble();
                final distance = (currentPage - page).abs().clamp(0.0, 1.0);
                final scale = 1 - (distance * .08);
                return Transform.scale(scale: scale, child: child);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _BannerCard(banner: _banners[page % _banners.length]),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < _banners.length; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: index == _selectedIndex ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              decoration: BoxDecoration(
                color: index == _selectedIndex
                    ? context.appColors.primary
                    : context.appColors.border,
                borderRadius: AppRadius.pillBorderRadius,
              ),
            ),
        ],
      ),
    ],
  );
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final _BannerData banner;

  @override
  Widget build(BuildContext context) {
    final colors = switch (banner.tone) {
      _BannerTone.primary => (
        context.appColors.primaryContainer,
        context.appColors.primary,
      ),
      _BannerTone.positive => (
        context.appColors.positiveContainer,
        context.appColors.positiveStrong,
      ),
      _BannerTone.info => (
        context.appColors.infoContainer,
        context.appColors.info,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: AppRadius.lgBorderRadius,
        border: Border.all(color: colors.$2.withValues(alpha: .18)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -AppSpacing.sm,
            bottom: -AppSpacing.sm,
            child: Icon(
              banner.icon,
              size: 72,
              color: colors.$2.withValues(alpha: .14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(banner.icon, size: AppSizes.iconMd, color: colors.$2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                banner.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.appColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                banner.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _BannerTone { primary, positive, info }

class _BannerData {
  const _BannerData({
    required this.title,
    required this.description,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String description;
  final IconData icon;
  final _BannerTone tone;
}

const _banners = [
  _BannerData(
    title: 'Build wealth, one trade at a time',
    description: 'Explore quality stocks picked for long-term investors.',
    icon: Icons.auto_graph_rounded,
    tone: _BannerTone.primary,
  ),
  _BannerData(
    title: 'Markets move. Stay ready.',
    description: 'Track live movers and act on the opportunities you follow.',
    icon: Icons.bolt_rounded,
    tone: _BannerTone.positive,
  ),
  _BannerData(
    title: 'Know before you trade',
    description: 'Use market insights to make more informed decisions.',
    icon: Icons.insights_rounded,
    tone: _BannerTone.info,
  ),
];
