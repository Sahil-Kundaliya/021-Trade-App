import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            title.toUpperCase(),
            style: context.appTextStyles.tableHeader.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.mdBorderRadius,
            border: Border.all(color: context.appColors.borderSubtle),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdBorderRadius,
            child: Column(
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  children[index],
                  if (index != children.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.huge),
                      child: Divider(color: context.appColors.divider),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
