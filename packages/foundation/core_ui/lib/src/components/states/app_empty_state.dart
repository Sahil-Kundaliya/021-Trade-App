import 'package:flutter/material.dart';

import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_sizes.dart';
import '../../theme/tokens/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String? description;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconLg,
              color: context.appColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                description!,
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
