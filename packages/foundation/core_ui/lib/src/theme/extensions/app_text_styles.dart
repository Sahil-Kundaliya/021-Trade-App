import 'package:flutter/material.dart';

@immutable
final class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.priceLarge,
    required this.priceMedium,
    required this.priceSmall,
    required this.marketValueLarge,
    required this.marketValueMedium,
    required this.percentageMedium,
    required this.percentageSmall,
    required this.tableHeader,
    required this.tableValue,
    required this.quantity,
    required this.orderValue,
  });

  factory AppTextStyles.fromTextTheme(TextTheme textTheme) {
    const tabularFigures = <FontFeature>[FontFeature.tabularFigures()];
    return AppTextStyles(
      priceLarge: textTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabularFigures,
      ),
      priceMedium: textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabularFigures,
      ),
      priceSmall: textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.w500,
        fontFeatures: tabularFigures,
      ),
      marketValueLarge: textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabularFigures,
      ),
      marketValueMedium: textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabularFigures,
      ),
      percentageMedium: textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabularFigures,
      ),
      percentageSmall: textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabularFigures,
      ),
      tableHeader: textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
      ),
      tableValue: textTheme.bodySmall!.copyWith(
        fontWeight: FontWeight.w500,
        fontFeatures: tabularFigures,
      ),
      quantity: textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w500,
        fontFeatures: tabularFigures,
      ),
      orderValue: textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabularFigures,
      ),
    );
  }

  final TextStyle priceLarge;
  final TextStyle priceMedium;
  final TextStyle priceSmall;
  final TextStyle marketValueLarge;
  final TextStyle marketValueMedium;
  final TextStyle percentageMedium;
  final TextStyle percentageSmall;
  final TextStyle tableHeader;
  final TextStyle tableValue;
  final TextStyle quantity;
  final TextStyle orderValue;

  @override
  AppTextStyles copyWith({
    TextStyle? priceLarge,
    TextStyle? priceMedium,
    TextStyle? priceSmall,
    TextStyle? marketValueLarge,
    TextStyle? marketValueMedium,
    TextStyle? percentageMedium,
    TextStyle? percentageSmall,
    TextStyle? tableHeader,
    TextStyle? tableValue,
    TextStyle? quantity,
    TextStyle? orderValue,
  }) {
    return AppTextStyles(
      priceLarge: priceLarge ?? this.priceLarge,
      priceMedium: priceMedium ?? this.priceMedium,
      priceSmall: priceSmall ?? this.priceSmall,
      marketValueLarge: marketValueLarge ?? this.marketValueLarge,
      marketValueMedium: marketValueMedium ?? this.marketValueMedium,
      percentageMedium: percentageMedium ?? this.percentageMedium,
      percentageSmall: percentageSmall ?? this.percentageSmall,
      tableHeader: tableHeader ?? this.tableHeader,
      tableValue: tableValue ?? this.tableValue,
      quantity: quantity ?? this.quantity,
      orderValue: orderValue ?? this.orderValue,
    );
  }

  @override
  AppTextStyles lerp(covariant AppTextStyles? other, double t) {
    if (other == null) return this;
    return AppTextStyles(
      priceLarge: TextStyle.lerp(priceLarge, other.priceLarge, t)!,
      priceMedium: TextStyle.lerp(priceMedium, other.priceMedium, t)!,
      priceSmall: TextStyle.lerp(priceSmall, other.priceSmall, t)!,
      marketValueLarge: TextStyle.lerp(
        marketValueLarge,
        other.marketValueLarge,
        t,
      )!,
      marketValueMedium: TextStyle.lerp(
        marketValueMedium,
        other.marketValueMedium,
        t,
      )!,
      percentageMedium: TextStyle.lerp(
        percentageMedium,
        other.percentageMedium,
        t,
      )!,
      percentageSmall: TextStyle.lerp(
        percentageSmall,
        other.percentageSmall,
        t,
      )!,
      tableHeader: TextStyle.lerp(tableHeader, other.tableHeader, t)!,
      tableValue: TextStyle.lerp(tableValue, other.tableValue, t)!,
      quantity: TextStyle.lerp(quantity, other.quantity, t)!,
      orderValue: TextStyle.lerp(orderValue, other.orderValue, t)!,
    );
  }
}
