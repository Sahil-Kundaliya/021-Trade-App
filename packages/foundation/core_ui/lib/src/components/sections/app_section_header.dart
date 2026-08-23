import 'package:flutter/material.dart';

import '../../theme/extensions/theme_context_extension.dart';

enum AppSectionHeaderLevel { page, section, card }

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.level = AppSectionHeaderLevel.section,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final AppSectionHeaderLevel level;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: switch (level) {
                  AppSectionHeaderLevel.page => context.appTextStyles.pageTitle,
                  AppSectionHeaderLevel.section =>
                    context.appTextStyles.sectionTitle,
                  AppSectionHeaderLevel.card => context.appTextStyles.cardTitle,
                },
              ),
              if (subtitle != null)
                Text(subtitle!, style: context.appTextStyles.bodySecondary),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
