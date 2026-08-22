import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trader_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, super.key});

  final TraderProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileAvatar(name: profile.fullName),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      profile.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.appColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (profile.isVerified) const _VerifiedBadge(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Client ID: ${profile.clientId}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${profile.accountType} Account',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.appColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.take(2).map((word) => word[0]).join().toUpperCase();

    return Semantics(
      label: '$name avatar',
      child: CircleAvatar(
        radius: AppSizes.iconLg,
        backgroundColor: context.appColors.primaryContainer,
        foregroundColor: context.appColors.onPrimaryContainer,
        child: Text(initials, style: context.textTheme.titleMedium),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Account verified',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_outlined,
            size: AppSizes.iconXs,
            color: context.appColors.positive,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Verified',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.appColors.positive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
