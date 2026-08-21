import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({this.controller, this.label, this.onChanged, super.key});

  final TextEditingController? controller;
  final String? label;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
}
