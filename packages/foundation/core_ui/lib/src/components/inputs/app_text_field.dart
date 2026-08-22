import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
    );
  }
}
