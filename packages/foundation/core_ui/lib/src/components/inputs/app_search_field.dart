import 'package:flutter/material.dart';

import '../../theme/tokens/app_sizes.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.showSearchIcon = true,
    super.key,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool showSearchIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: showSearchIcon
            ? const Icon(Icons.search, size: AppSizes.iconSm)
            : null,
        suffixIcon: onClear == null
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: AppSizes.iconSm),
                tooltip: 'Clear search',
              ),
      ),
    );
  }
}
