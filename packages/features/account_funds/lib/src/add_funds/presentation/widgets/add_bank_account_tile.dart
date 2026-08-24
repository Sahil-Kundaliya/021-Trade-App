import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class AddBankAccountTile extends StatelessWidget {
  const AddBankAccountTile({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surface,
      borderRadius: AppRadius.mdBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorderRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  size: AppSizes.iconSm,
                  color: context.appColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Add New Bank Account',
                  style: context.appTextStyles.bodyMedium.copyWith(
                    color: context.appColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
