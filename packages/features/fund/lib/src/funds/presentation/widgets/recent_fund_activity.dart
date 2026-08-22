import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/fund_activity.dart';
import 'fund_activity_tile.dart';

class RecentFundActivity extends StatelessWidget {
  const RecentFundActivity({required this.activities, super.key});

  final List<FundActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Recent Fund Activity'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              for (var index = 0; index < activities.length; index++) ...[
                FundActivityTile(activity: activities[index]),
                if (index != activities.length - 1) const AppDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
