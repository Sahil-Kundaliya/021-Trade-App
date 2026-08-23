abstract final class FundFormat {
  static String money(num? value) =>
      value == null ? '—' : '₹${group(value.toStringAsFixed(2))}';

  static String signedMoney(num value) =>
      '${value >= 0 ? '+' : '-'}₹${group(value.abs().toStringAsFixed(2))}';

  static String percent(num value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';

  static String integer(int? value) =>
      value == null ? '—' : group(value.toString());

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

  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  static String group(String source) {
    final parts = source.split('.');
    var whole = parts.first;
    final negative = whole.startsWith('-');
    if (negative) whole = whole.substring(1);
    if (whole.length > 3) {
      final end = whole.substring(whole.length - 3);
      var start = whole.substring(0, whole.length - 3);
      final groups = <String>[];
      while (start.length > 2) {
        groups.insert(0, start.substring(start.length - 2));
        start = start.substring(0, start.length - 2);
      }
      if (start.isNotEmpty) groups.insert(0, start);
      whole = '${groups.join(',')},$end';
    }
    return '${negative ? '-' : ''}$whole${parts.length > 1 ? '.${parts[1]}' : ''}';
  }
}
