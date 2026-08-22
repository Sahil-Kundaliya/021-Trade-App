import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: Material(
        color: context.appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdBorderRadius,
          side: BorderSide(color: context.appColors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: AppSizes.iconSm,
                    color: context.appColors.negative,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Log Out',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.negative,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
