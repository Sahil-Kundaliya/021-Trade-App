import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

Future<void> showAddBankDemoSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const AddBankDemoSheet(),
  );
}

class AddBankDemoSheet extends StatelessWidget {
  const AddBankDemoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ADD BANK ACCOUNT',
                    style: context.appTextStyles.tableHeader.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AppTextField(
                    label: 'Bank Name',
                    hint: 'Select Bank',
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppTextField(
                    label: 'Account Holder Name',
                    hint: 'Demo User',
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppTextField(
                    label: 'Account Number',
                    hint: '••••••••••••',
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppTextField(
                    label: 'Confirm Account Number',
                    hint: '••••••••••••',
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppTextField(
                    label: 'IFSC',
                    hint: 'ABCD0000000',
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppDropdown<String>(
                    label: 'Account Type',
                    initialValue: 'Savings',
                    items: [
                      DropdownMenuItem(
                        value: 'Savings',
                        child: Text('Savings'),
                      ),
                      DropdownMenuItem(
                        value: 'Current',
                        child: Text('Current'),
                      ),
                    ],
                    onChanged: null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Demo only',
                    style: context.appTextStyles.bodyMedium.copyWith(
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Bank account linking is not available in this local trading demo.',
                    style: context.appTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'CLOSE',
                    expand: true,
                    onPressed: () => Navigator.pop(context),
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
