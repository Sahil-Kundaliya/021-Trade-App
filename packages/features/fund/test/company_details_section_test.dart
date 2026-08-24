import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fund/src/fund_details/domain/entities/fund_details.dart';
import 'package:fund/src/fund_details/presentation/widgets/company_details_section.dart';

void main() {
  testWidgets('contact links launch website, email, and phone URIs', (
    tester,
  ) async {
    final launched = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyDetailsSection(
              profile: _profile,
              contactLauncher: (uri) async {
                launched.add(uri);
                return true;
              },
            ),
          ),
        ),
      ),
    );

    for (final value in [
      'example.com',
      'investors@example.com',
      '+91 22 1234 5678',
    ]) {
      await tester.ensureVisible(find.text(value));
      await tester.tap(find.text(value));
      await tester.pump();
    }

    expect(launched, [
      Uri.parse('https://example.com'),
      Uri.parse('mailto:investors@example.com'),
      Uri.parse('tel:+912212345678'),
    ]);
    expect(find.byIcon(Icons.open_in_new_rounded), findsNothing);
  });

  testWidgets('failed contact launch reports a user-facing message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyDetailsSection(
              profile: _profile,
              contactLauncher: (_) async => false,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('example.com'));
    await tester.pump();

    expect(find.text('Unable to open Website.'), findsOneWidget);
  });
}

const _profile = CompanyProfile(
  legalName: 'Example Limited',
  industry: 'Technology',
  registeredOffice: '1 Example Road, Bengaluru',
  corporateIdentityNumber: 'L00000KA2000PLC000000',
  website: 'example.com',
  email: 'investors@example.com',
  phone: '+91 22 1234 5678',
  directors: [CompanyPerson(name: 'Director One', role: 'Director')],
  management: [CompanyPerson(name: 'Manager One', role: 'CEO')],
);
