import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrderChoiceSelector<T> extends StatelessWidget {
  const OrderChoiceSelector({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.errorText,
    super.key,
  });
  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.textTheme.labelLarge),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: values
            .map(
              (value) => AppChip(
                label: labelOf(value),
                selected: value == selected,
                onSelected: (_) => onChanged(value),
              ),
            )
            .toList(),
      ),
      if (errorText != null) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          errorText!,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.appColors.negative,
          ),
        ),
      ],
    ],
  );
}
