import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    required this.quantity,
    required this.lotSize,
    required this.isDerivative,
    this.onIncrement,
    required this.onDecrement,
    required this.onChanged,
    this.errorText,
    super.key,
  });
  final int quantity;
  final int lotSize;
  final bool isDerivative;
  final VoidCallback? onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != '${widget.quantity}') {
      _controller.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots = widget.lotSize == 0 ? 0 : widget.quantity ~/ widget.lotSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isDerivative ? 'Quantity / Lots' : 'Quantity',
          style: context.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: widget.onDecrement,
              icon: const Icon(Icons.remove),
              tooltip: 'Decrease quantity',
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppTextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: widget.onChanged,
                errorText: widget.errorText,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filledTonal(
              onPressed: widget.onIncrement,
              icon: const Icon(Icons.add),
              tooltip: 'Increase quantity',
            ),
          ],
        ),
        if (widget.isDerivative)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              '$lots ${lots == 1 ? 'Lot' : 'Lots'} · ${widget.quantity} Qty',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
