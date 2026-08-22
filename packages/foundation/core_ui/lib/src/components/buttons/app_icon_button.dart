import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: icon, tooltip: tooltip);
  }
}
