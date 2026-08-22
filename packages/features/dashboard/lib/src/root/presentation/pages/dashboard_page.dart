import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../market/presentation/widgets/market_screener.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: MarketScreener(),
        ),
      ),
    );
  }
}
