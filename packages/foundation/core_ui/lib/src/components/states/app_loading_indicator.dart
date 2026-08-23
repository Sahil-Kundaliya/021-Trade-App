import 'package:flutter/material.dart';

import '../../theme/tokens/app_sizes.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.centered = true, super.key});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    const indicator = SizedBox.square(
      dimension: AppSizes.iconMd,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    return centered ? const Center(child: indicator) : indicator;
  }
}
