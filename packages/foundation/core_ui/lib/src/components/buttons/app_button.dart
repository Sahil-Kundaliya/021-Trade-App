import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = leadingIcon == null
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            icon: leadingIcon!,
            label: Text(label),
          );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
