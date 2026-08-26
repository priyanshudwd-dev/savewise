import 'package:intl/intl.dart';

import '../l10n/L.dart';

final _nf = NumberFormat('#,##0', 'en_IN');

String money(num v, String sym) => '$sym${_nf.format(v.round())}';

String signed(num v, String sym) =>
    '${v < 0 ? '-' : '+'}$sym${_nf.format(v.abs().round())}';

extension DTX on DateTime {
  bool sameDay(DateTime o) =>
      year == o.year && month == o.month && day == o.day;

  DateTime get dayOnly => DateTime(year, month, day);

  bool inMonth(int y, int m) => year == y && month == m;
}

String dayLabel(L l, DateTime d) {
  final now = DateTime.now();
  if (d.sameDay(now)) return l.t('today');
  if (d.sameDay(now.subtract(const Duration(days: 1)))) return l.t('yesterday');
  return DateFormat('d MMM yyyy').format(d);
}

String shortDate(DateTime d) => DateFormat('d MMM').format(d);

int daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;
