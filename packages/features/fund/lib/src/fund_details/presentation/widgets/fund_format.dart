import 'package:core_ui/core_ui.dart';

abstract final class FundFormat {
  static String money(num? value) =>
      value == null ? '—' : FinancialFormatter.price(value.toDouble());

  static String signedMoney(num value) =>
      FinancialFormatter.signedPrice(value.toDouble());

  static String percent(num value) =>
      FinancialFormatter.percentage(value.toDouble());

  static String integer(int? value) =>
      value == null ? '—' : FinancialFormatter.group(value.toString());

  static String compact(int value) => value >= 1000000
      ? '${(value / 1000000).toStringAsFixed(2)}M'
      : value >= 1000
      ? '${(value / 1000).toStringAsFixed(1)}K'
      : '$value';

  static String date(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  static String expiryChip(DateTime value) => date(value).toUpperCase();

  static String axisDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  static String group(String source) => FinancialFormatter.group(source);
}
