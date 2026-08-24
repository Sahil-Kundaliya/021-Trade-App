import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/account_funds_amount_formatter.dart';

class AddFundsAmountField extends StatefulWidget {
  const AddFundsAmountField({
    required this.amountInput,
    required this.onChanged,
    this.validationMessage,
    this.enabled = true,
    super.key,
  });

  final String amountInput;
  final ValueChanged<String> onChanged;
  final String? validationMessage;
  final bool enabled;

  @override
  State<AddFundsAmountField> createState() => _AddFundsAmountFieldState();
}

class _AddFundsAmountFieldState extends State<AddFundsAmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.amountInput);
  }

  @override
  void didUpdateWidget(covariant AddFundsAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amountInput != oldWidget.amountInput &&
        widget.amountInput != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.amountInput,
        selection: TextSelection.collapsed(offset: widget.amountInput.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = context.appTextStyles.financialHero.copyWith(
      color: context.appColors.textPrimary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ENTER AMOUNT',
          style: context.appTextStyles.tableHeader.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const <TextInputFormatter>[
            AccountFundsAmountFormatter(),
          ],
          style: style,
          cursorColor: context.appColors.primary,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: style,
            hintText: '0.00',
            hintStyle: style.copyWith(color: context.appColors.textTertiary),
            errorText: widget.validationMessage,
            errorStyle: context.appTextStyles.caption.copyWith(
              color: context.appColors.negative,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Maximum ₹10,000 per add',
          textAlign: TextAlign.center,
          style: context.appTextStyles.caption.copyWith(
            color: context.appColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
