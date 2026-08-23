import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class ProfileSettingTile extends StatelessWidget {
  const ProfileSettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.status,
    this.statusIsPositive = false,
    this.trailing,
    this.showChevron = true,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final String? status;
  final bool statusIsPositive;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: Material(
        color: context.appColors.surface,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Icon(
                        icon,
                        size: AppSizes.iconSm,
                        color: context.appColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: context.appTextStyles.bodyMedium.copyWith(
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                subtitle!,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.45,
                        ),
                        child: _ProfileSettingTrailing(
                          value: value,
                          status: status,
                          statusIsPositive: statusIsPositive,
                          trailing: trailing,
                          showChevron: showChevron,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSettingTrailing extends StatelessWidget {
  const _ProfileSettingTrailing({
    required this.value,
    required this.status,
    required this.statusIsPositive,
    required this.trailing,
    required this.showChevron,
  });

  final String? value;
  final String? status;
  final bool statusIsPositive;
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (value != null)
          Flexible(
            child: Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        if (status != null)
          Flexible(
            child: Text(
              status!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: context.appTextStyles.statusLabel.copyWith(
                color: statusIsPositive
                    ? context.appColors.positive
                    : context.appColors.textSecondary,
              ),
            ),
          ),
        ?trailing,
        if (showChevron) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right,
            size: AppSizes.iconSm,
            color: context.appColors.textTertiary,
          ),
        ],
      ],
    );
  }
}
