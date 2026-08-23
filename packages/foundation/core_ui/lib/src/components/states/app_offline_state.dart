import 'package:flutter/material.dart';

import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_sizes.dart';
import '../../theme/tokens/app_spacing.dart';
import '../buttons/app_button.dart';

class AppOfflineState extends StatelessWidget {
  const AppOfflineState({
    required this.onRetry,
    this.compact = false,
    super.key,
  });

  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: compact ? AppSizes.iconMd : AppSizes.iconLg,
            color: context.appColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Internet Connection',
            textAlign: TextAlign.center,
            style: context.appTextStyles.cardTitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "You're offline. Check your connection and try again.",
            textAlign: TextAlign.center,
            style: context.appTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Retry', onPressed: onRetry),
        ],
      ),
    ),
  );
}
