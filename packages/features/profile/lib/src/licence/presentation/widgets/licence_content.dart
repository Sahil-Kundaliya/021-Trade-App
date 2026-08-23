import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../demo_licence_data.dart';

class LicenceContent extends StatelessWidget {
  const LicenceContent({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Licence & Regulatory Information')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DemoNotice(),
                SizedBox(height: AppSpacing.lg),
                _LicenceSection(
                  title: 'Broker Information',
                  rows: [
                    ('Legal Name', DemoLicenceData.legalName),
                    ('Trading Name', DemoLicenceData.tradingName),
                    ('Entity Type', DemoLicenceData.entityType),
                    ('CIN', DemoLicenceData.cin),
                    ('Registered Country', DemoLicenceData.country),
                  ],
                ),
                _LicenceSection(
                  title: 'SEBI Registration',
                  rows: [
                    ('Registration Type', 'Stock Broker'),
                    ('Registration Number', DemoLicenceData.sebiRegistration),
                    ('Registration Status', 'Demo / Not a Real Registration'),
                  ],
                ),
                _LicenceSection(
                  title: 'Exchange Memberships',
                  rows: [
                    (
                      'National Stock Exchange of India',
                      'Member ID: ${DemoLicenceData.nseMemberId}\nSegments: Equity · Equity Derivatives',
                    ),
                    (
                      'Bombay Stock Exchange',
                      'Member ID: ${DemoLicenceData.bseMemberId}\nSegments: Equity · Equity Derivatives',
                    ),
                  ],
                ),
                _LicenceSection(
                  title: 'Depository Participant',
                  rows: [
                    ('Depository', 'CDSL'),
                    ('DP Registration', DemoLicenceData.dpRegistration),
                    ('DP ID', DemoLicenceData.dpId),
                  ],
                ),
                _LicenceSection(
                  title: 'Trading Segments',
                  rows: [
                    ('Equity', 'Enabled'),
                    ('Equity Futures', 'Enabled'),
                    ('Equity Options', 'Enabled'),
                  ],
                ),
                _LicenceSection(
                  title: 'Registered Office',
                  rows: [('Demo / Fictional Address', DemoLicenceData.office)],
                ),
                _LicenceSection(
                  title: 'Compliance',
                  rows: [
                    ('Compliance Officer', DemoLicenceData.complianceOfficer),
                    ('Email', DemoLicenceData.complianceEmail),
                    ('Phone', DemoLicenceData.compliancePhone),
                  ],
                ),
                _LicenceSection(
                  title: 'Investor Grievance',
                  rows: [
                    ('Grievance Officer', DemoLicenceData.grievanceOfficer),
                    ('Email', DemoLicenceData.grievanceEmail),
                    (
                      'Reference',
                      'Investor grievance requests should follow applicable exchange, depository and SEBI grievance procedures.',
                    ),
                  ],
                ),
                _LicenceSection(
                  title: 'Regulatory Authorities',
                  rows: [
                    ('SEBI', 'Securities and Exchange Board of India'),
                    ('NSE', 'National Stock Exchange of India'),
                    ('BSE', 'BSE Limited'),
                    ('CDSL', 'Central Depository Services (India) Limited'),
                  ],
                ),
                _LicenceSection(
                  title: 'Risk Disclosure',
                  rows: [
                    (
                      'Market Risk',
                      'Investments in securities markets are subject to market risks. Read all related documents carefully before investing.',
                    ),
                  ],
                ),
                _ImportantNotice(),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.appColors.warningContainer,
      borderRadius: AppRadius.mdBorderRadius,
      border: Border.all(color: context.appColors.warning),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: context.appColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Demo Regulatory Information',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'The registration and membership information shown on this screen is fictional and provided only for demonstration purposes.',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'NOT A REAL REGISTRATION',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.appColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _LicenceSection extends StatelessWidget {
  const _LicenceSection({required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: context.appTextStyles.tableHeader.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.mdBorderRadius,
            border: Border.all(color: context.appColors.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  _LicenceRow(label: rows[index].$1, value: rows[index].$2),
                  if (index < rows.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Divider(color: context.appColors.divider),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _LicenceRow extends StatelessWidget {
  const _LicenceRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      SelectableText(
        value,
        textAlign: TextAlign.start,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _ImportantNotice extends StatelessWidget {
  const _ImportantNotice();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.appColors.infoContainer,
      borderRadius: AppRadius.mdBorderRadius,
      border: Border.all(color: context.appColors.info),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IMPORTANT',
            style: context.appTextStyles.tableHeader.copyWith(
              color: context.appColors.info,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This application is a demonstration project.\n\nAll broker names, registration numbers, exchange member IDs, DP IDs, addresses and compliance contacts displayed on this screen are fictional demo values.\n\nThey must not be used to represent a real regulated entity.',
          ),
        ],
      ),
    ),
  );
}
