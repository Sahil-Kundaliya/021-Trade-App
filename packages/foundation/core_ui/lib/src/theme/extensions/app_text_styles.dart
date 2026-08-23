import 'package:flutter/material.dart';

/// Semantic typography for compact, data-dense trading interfaces.
@immutable
final class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.body,
    required this.bodyMedium,
    required this.bodySecondary,
    required this.label,
    required this.caption,
    required this.button,
    required this.marketSymbol,
    required this.marketCompany,
    required this.financialHero,
    required this.financialLarge,
    required this.financialMedium,
    required this.financialRegular,
    required this.financialSmall,
    required this.financialCaption,
    required this.tableHeader,
    required this.tableCell,
    required this.statusLabel,
  });

  factory AppTextStyles.fromTextTheme(TextTheme textTheme) {
    const tabularFigures = <FontFeature>[FontFeature.tabularFigures()];
    TextStyle numeric(TextStyle style) =>
        style.copyWith(fontFeatures: tabularFigures);

    return AppTextStyles(
      pageTitle: textTheme.titleLarge!,
      pageSubtitle: textTheme.bodyMedium!,
      sectionTitle: textTheme.titleSmall!.copyWith(
        fontSize: 13,
        height: 18 / 13,
        letterSpacing: 0.35,
      ),
      cardTitle: textTheme.titleMedium!,
      body: textTheme.bodyMedium!,
      bodyMedium: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
      bodySecondary: textTheme.bodySmall!,
      label: textTheme.labelMedium!,
      caption: textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400),
      button: textTheme.labelLarge!,
      marketSymbol: textTheme.titleMedium!,
      marketCompany: textTheme.bodySmall!,
      financialHero: numeric(
        textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w600),
      ),
      financialLarge: numeric(
        textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
      ),
      financialMedium: numeric(
        textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500),
      ),
      financialRegular: numeric(
        textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
      ),
      financialSmall: numeric(
        textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
      ),
      financialCaption: numeric(
        textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w500),
      ),
      tableHeader: textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
      ),
      tableCell: numeric(
        textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500),
      ),
      statusLabel: textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
      ),
    );
  }

  final TextStyle pageTitle;
  final TextStyle pageSubtitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle body;
  final TextStyle bodyMedium;
  final TextStyle bodySecondary;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle marketSymbol;
  final TextStyle marketCompany;
  final TextStyle financialHero;
  final TextStyle financialLarge;
  final TextStyle financialMedium;
  final TextStyle financialRegular;
  final TextStyle financialSmall;
  final TextStyle financialCaption;
  final TextStyle tableHeader;
  final TextStyle tableCell;
  final TextStyle statusLabel;

  // Compatibility aliases for the original public API.
  TextStyle get priceLarge => financialHero;
  TextStyle get priceMedium => financialLarge;
  TextStyle get priceSmall => financialMedium;
  TextStyle get marketValueLarge => financialLarge;
  TextStyle get marketValueMedium => financialMedium;
  TextStyle get percentageMedium => financialRegular;
  TextStyle get percentageSmall => financialCaption;
  TextStyle get tableValue => tableCell;
  TextStyle get quantity => financialRegular;
  TextStyle get orderValue => financialMedium;

  @override
  AppTextStyles copyWith({
    TextStyle? pageTitle,
    TextStyle? pageSubtitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? body,
    TextStyle? bodyMedium,
    TextStyle? bodySecondary,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? marketSymbol,
    TextStyle? marketCompany,
    TextStyle? financialHero,
    TextStyle? financialLarge,
    TextStyle? financialMedium,
    TextStyle? financialRegular,
    TextStyle? financialSmall,
    TextStyle? financialCaption,
    TextStyle? tableHeader,
    TextStyle? tableCell,
    TextStyle? statusLabel,
    TextStyle? priceLarge,
    TextStyle? priceMedium,
  }) => AppTextStyles(
    pageTitle: pageTitle ?? this.pageTitle,
    pageSubtitle: pageSubtitle ?? this.pageSubtitle,
    sectionTitle: sectionTitle ?? this.sectionTitle,
    cardTitle: cardTitle ?? this.cardTitle,
    body: body ?? this.body,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySecondary: bodySecondary ?? this.bodySecondary,
    label: label ?? this.label,
    caption: caption ?? this.caption,
    button: button ?? this.button,
    marketSymbol: marketSymbol ?? this.marketSymbol,
    marketCompany: marketCompany ?? this.marketCompany,
    financialHero: financialHero ?? priceLarge ?? this.financialHero,
    financialLarge: financialLarge ?? priceMedium ?? this.financialLarge,
    financialMedium: financialMedium ?? this.financialMedium,
    financialRegular: financialRegular ?? this.financialRegular,
    financialSmall: financialSmall ?? this.financialSmall,
    financialCaption: financialCaption ?? this.financialCaption,
    tableHeader: tableHeader ?? this.tableHeader,
    tableCell: tableCell ?? this.tableCell,
    statusLabel: statusLabel ?? this.statusLabel,
  );

  @override
  AppTextStyles lerp(covariant AppTextStyles? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTextStyles(
      pageTitle: mix(pageTitle, other.pageTitle),
      pageSubtitle: mix(pageSubtitle, other.pageSubtitle),
      sectionTitle: mix(sectionTitle, other.sectionTitle),
      cardTitle: mix(cardTitle, other.cardTitle),
      body: mix(body, other.body),
      bodyMedium: mix(bodyMedium, other.bodyMedium),
      bodySecondary: mix(bodySecondary, other.bodySecondary),
      label: mix(label, other.label),
      caption: mix(caption, other.caption),
      button: mix(button, other.button),
      marketSymbol: mix(marketSymbol, other.marketSymbol),
      marketCompany: mix(marketCompany, other.marketCompany),
      financialHero: mix(financialHero, other.financialHero),
      financialLarge: mix(financialLarge, other.financialLarge),
      financialMedium: mix(financialMedium, other.financialMedium),
      financialRegular: mix(financialRegular, other.financialRegular),
      financialSmall: mix(financialSmall, other.financialSmall),
      financialCaption: mix(financialCaption, other.financialCaption),
      tableHeader: mix(tableHeader, other.tableHeader),
      tableCell: mix(tableCell, other.tableCell),
      statusLabel: mix(statusLabel, other.statusLabel),
    );
  }
}
