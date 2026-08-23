import 'package:flutter/material.dart';

import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_sizes.dart';
import '../../theme/tokens/app_spacing.dart';
import '../buttons/app_button.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    this.description,
    this.onRetry,
    this.actionLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final String actionLabel;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? AppSizes.iconMd : AppSizes.iconLg,
            color: context.appColors.negative,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.appTextStyles.cardTitle,
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: context.appTextStyles.bodySecondary,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: actionLabel, onPressed: onRetry),
          ],
        ],
      ),
    ),
  );
}
