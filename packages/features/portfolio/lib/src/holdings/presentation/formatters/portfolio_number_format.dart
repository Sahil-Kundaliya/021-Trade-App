import 'package:core_ui/core_ui.dart';

abstract final class PortfolioNumberFormat {
  static String currency(double value) => FinancialFormatter.price(value);

  static String signedCurrency(double value) =>
      FinancialFormatter.signedPrice(value);

  static String percentage(double value) =>
      FinancialFormatter.percentage(value);

  static String number(double value) =>
      FinancialFormatter.group(FinancialFormatter.decimals(value.abs()));
}
