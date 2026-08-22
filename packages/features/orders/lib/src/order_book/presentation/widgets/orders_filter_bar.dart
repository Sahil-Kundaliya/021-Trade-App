import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrdersFilterBar extends StatefulWidget {
  const OrdersFilterBar({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const OrdersFilterBar(),
    );
  }

  @override
  State<OrdersFilterBar> createState() => _OrdersFilterBarState();
}

class _OrdersFilterBarState extends State<OrdersFilterBar> {
  final _selected = <String, String>{
    'Status': 'All',
    'Side': 'All',
    'Exchange': 'All',
    'Order Type': 'All',
    'Product': 'All',
  };

  static const _options = <String, List<String>>{
    'Status': ['All', 'Open', 'Executed', 'Cancelled'],
    'Side': ['All', 'Buy', 'Sell'],
    'Exchange': ['All', 'NSE', 'BSE'],
    'Order Type': ['All', 'Market', 'Limit', 'SL', 'SL-M'],
    'Product': ['All', 'Delivery', 'Intraday'],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Orders', style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xl),
              for (final entry in _options.entries) ...[
                _FilterGroup(
                  label: entry.key,
                  options: entry.value,
                  selected: _selected[entry.key]!,
                  onSelected: (value) {
                    setState(() => _selected[entry.key] = value);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          for (final key in _selected.keys) {
                            _selected[key] = 'All';
                          }
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Apply',
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.appColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final option in options)
              AppChip(
                label: option,
                selected: option == selected,
                onSelected: (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}
