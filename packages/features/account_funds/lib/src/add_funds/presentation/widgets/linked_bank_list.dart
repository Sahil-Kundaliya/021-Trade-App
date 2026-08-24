import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/linked_bank_account.dart';
import 'linked_bank_tile.dart';

class LinkedBankList extends StatelessWidget {
  const LinkedBankList({
    required this.banks,
    required this.selectedBankId,
    required this.onSelected,
    super.key,
  });

  final List<LinkedBankAccount> banks;
  final String? selectedBankId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAY USING',
          style: context.appTextStyles.tableHeader.copyWith(
            color: context.appColors.textSecondary,
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
                for (var index = 0; index < banks.length; index++) ...[
                  LinkedBankTile(
                    bank: banks[index],
                    selected: banks[index].id == selectedBankId,
                    onSelected: onSelected,
                  ),
                  if (index != banks.length - 1)
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
