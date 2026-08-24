import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/fund_details.dart';

typedef CompanyContactLauncher = Future<bool> Function(Uri uri);

class CompanyDetailsSection extends StatelessWidget {
  const CompanyDetailsSection({
    required this.profile,
    this.contactLauncher,
    super.key,
  });

  final CompanyProfile profile;
  final CompanyContactLauncher? contactLauncher;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeader(
        title: 'COMPANY DETAILS',
        subtitle: 'Corporate profile and key people',
      ),
      const SizedBox(height: AppSpacing.lg),
      _CompanyIdentity(profile: profile),
      const SizedBox(height: AppSpacing.lg),
      const AppDivider(),
      const SizedBox(height: AppSpacing.lg),
      _Address(address: profile.registeredOffice),
      const SizedBox(height: AppSpacing.lg),
      const AppDivider(),
      const SizedBox(height: AppSpacing.lg),
      _PeopleGroup(title: 'DIRECTORS', people: profile.directors),
      const SizedBox(height: AppSpacing.lg),
      const AppDivider(),
      const SizedBox(height: AppSpacing.lg),
      _PeopleGroup(title: 'KEY MANAGEMENT', people: profile.management),
      const SizedBox(height: AppSpacing.lg),
      const AppDivider(),
      const SizedBox(height: AppSpacing.lg),
      _ContactInformation(
        profile: profile,
        launcher: contactLauncher ?? _launchExternally,
      ),
    ],
  );
}

class _CompanyIdentity extends StatelessWidget {
  const _CompanyIdentity({required this.profile});

  final CompanyProfile profile;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _IconBox(icon: Icons.apartment_rounded),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.legalName,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.industry,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'CIN ${profile.corporateIdentityNumber}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.appColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Address extends StatelessWidget {
  const _Address({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) => _DetailBlock(
    icon: Icons.location_on_outlined,
    title: 'REGISTERED OFFICE',
    child: Text(
      address,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.appColors.textSecondary,
        height: 1.5,
      ),
    ),
  );
}

class _PeopleGroup extends StatelessWidget {
  const _PeopleGroup({required this.title, required this.people});

  final String title;
  final List<CompanyPerson> people;

  @override
  Widget build(BuildContext context) => _DetailBlock(
    icon: Icons.groups_2_outlined,
    title: title,
    child: people.isEmpty
        ? Text(
            'Information unavailable',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          )
        : Column(
            children: [
              for (var index = 0; index < people.length; index++) ...[
                _PersonRow(person: people[index]),
                if (index < people.length - 1) const AppDivider(),
              ],
            ],
          ),
  );
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person});

  final CompanyPerson person;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.person_outline_rounded,
          size: AppSizes.iconSm,
          color: context.appColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                person.role,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ContactInformation extends StatelessWidget {
  const _ContactInformation({required this.profile, required this.launcher});

  final CompanyProfile profile;
  final CompanyContactLauncher launcher;

  @override
  Widget build(BuildContext context) => _DetailBlock(
    icon: Icons.contact_phone_outlined,
    title: 'CONTACT INFORMATION',
    child: Column(
      children: [
        _ContactRow(
          icon: Icons.language_rounded,
          label: 'Website',
          value: profile.website,
          uri: _websiteUri(profile.website),
          launcher: launcher,
        ),
        const AppDivider(),
        _ContactRow(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: profile.email,
          uri: Uri(scheme: 'mailto', path: profile.email),
          launcher: launcher,
        ),
        const AppDivider(),
        _ContactRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: profile.phone,
          uri: Uri(scheme: 'tel', path: profile.phone.replaceAll(' ', '')),
          launcher: launcher,
        ),
      ],
    ),
  );
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.uri,
    required this.launcher,
  });

  final IconData icon;
  final String label;
  final String value;
  final Uri uri;
  final CompanyContactLauncher launcher;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Open $label $value',
    child: InkWell(
      borderRadius: AppRadius.smBorderRadius,
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppSizes.iconXs, color: context.appColors.primary),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 64,
              child: Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: context.appColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _open(BuildContext context) async {
    try {
      final opened = await launcher(uri);
      if (!opened && context.mounted) _showFailure(context);
    } on Object {
      if (context.mounted) _showFailure(context);
    }
  }

  void _showFailure(BuildContext context) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text('Unable to open $label.')));
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: context.appColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: context.appTextStyles.tableHeader),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      child,
    ],
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: AppSizes.touchTarget,
    height: AppSizes.touchTarget,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.appColors.primaryContainer,
      borderRadius: AppRadius.mdBorderRadius,
    ),
    child: Icon(icon, color: context.appColors.primary),
  );
}

Uri _websiteUri(String value) {
  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme) return parsed;
  return Uri.https(value, '');
}

Future<bool> _launchExternally(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);
