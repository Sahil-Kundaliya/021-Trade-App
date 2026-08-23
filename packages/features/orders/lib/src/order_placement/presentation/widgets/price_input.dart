import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class PriceInput extends StatefulWidget {
  const PriceInput({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });
  final String label;
  final double? value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant PriceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        double.tryParse(_controller.text) != widget.value) {
      _controller.text = widget.value?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: _controller,
    label: widget.label,
    prefixIcon: const Icon(Icons.currency_rupee),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: widget.onChanged,
    errorText: widget.errorText,
  );
}
