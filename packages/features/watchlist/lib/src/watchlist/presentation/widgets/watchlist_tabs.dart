import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WatchlistTabs extends StatelessWidget {
  const WatchlistTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.onAddPressed,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.touchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == labels.length) {
            return _AddWatchlistButton(onPressed: onAddPressed);
          }

          return _WatchlistTab(
            label: labels[index],
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? context.appColors.selection
        : context.appColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? context.appColors.selectionContainer
            : context.appColors.surfaceLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smBorderRadius,
          side: BorderSide(
            color: selected
                ? context.appColors.selection
                : context.appColors.borderSubtle,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              child: Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddWatchlistButton extends StatelessWidget {
  const _AddWatchlistButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Create watchlist',
      child: Material(
        color: context.appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smBorderRadius,
          side: BorderSide(color: context.appColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? _noOp,
          child: SizedBox.square(
            dimension: AppSizes.touchTarget,
            child: Icon(
              Icons.add,
              size: AppSizes.iconSm,
              color: context.appColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

void _noOp() {}
