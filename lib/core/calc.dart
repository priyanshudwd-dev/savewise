import 'dart:math';

import 'format.dart';

double pctOf(num a, num b) => b <= 0 ? 0 : (a / b * 100).clamp(0, 500).toDouble();

double pacePerDay(double outT, int daysElapsed) {
  final d = daysElapsed.clamp(1, 31);
  return outT / d;
}

double projectedSpend(double pace, int daysInMonth) => pace * daysInMonth;

int monthsTo(DateTime target) {
  final now = DateTime.now();
  var m = (target.year - now.year) * 12 + (target.month - now.month);
  if (target.day < now.day) m--;
  return m < 0 ? 0 : m;
}

double reqMonthly(double remaining, DateTime target) {
  final m = max(monthsTo(target), 0);
  if (m <= 0) return remaining;
  return remaining / m;
}

int streakDays(List<DateTime> days) {
  final set = days.map((d) => d.dayOnly).toSet();
  var cur = DateTime.now().dayOnly;
  if (!set.contains(cur)) {
    cur = cur.subtract(const Duration(days: 1));
    if (!set.contains(cur)) return 0;
  }
  var n = 0;
  while (set.contains(cur)) {
    n++;
    cur = cur.subtract(const Duration(days: 1));
  }
  return n;
}
