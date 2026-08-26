import 'dart:math';

import 'package:flutter/material.dart';

import '../core/calc.dart';
import '../core/format.dart';
import '../data/models.dart';
import '../data/repo.dart';
import '../l10n/L.dart';
import '../services/notif.dart';

class Store extends ChangeNotifier {
  Store(this._repo, this._notif);

  final Repo _repo;
  final Notif _notif;

  AppData d = AppData();
  List<String> fresh = [];

  Future<void> bootstrap() async {
    d = await _repo.load();
    ensurePrevReport();
    checkAchievements(silent: true);
    syncDaily();
    notifyListeners();
  }

  void syncDaily() {
    if (st.nDaily) {
      final p = st.dailyTime.split(':');
      final h = int.tryParse(p[0]) ?? 20;
      final m = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
      _notif.scheduleDaily(h, m, 'SaveWise',
          l.msg(MsgType.daily, st.personality, {}));
    } else {
      _notif.cancelAllSchedules();
    }
  }

  Settings get st => d.st;
  String get lang => st.lang;
  ThemeMode get themeMode => switch (st.theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
  String get sym => symbols[st.currency] ?? st.currency;
  bool get onboarded => st.onboarded;
  L get l => L(lang);

  void persist() => _repo.save(d);

  void bump() {
    persist();
    checkAchievements(silent: false);
    notifyListeners();
  }

  void patch(void Function(Settings) fn) {
    fn(st);
    syncDaily();
    bump();
  }

  void setName(String v) {
    st.name = v;
    persist();
    notifyListeners();
  }

  void finishOnboarding() {
    st.onboarded = true;
    persist();
    notifyListeners();
  }

  void replaceAll(AppData nd) {
    d = nd;
    persist();
    notifyListeners();
  }

  MonthStats statsFor(int y, int m) {
    var inT = 0.0;
    var outT = 0.0;
    final byCat = <String, double>{};
    for (final t in d.txs) {
      if (!t.date.inMonth(y, m)) continue;
      if (t.kind == Kind.credit) {
        inT += t.amount;
      } else {
        outT += t.amount;
        byCat[t.key] = (byCat[t.key] ?? 0) + t.amount;
      }
    }
    var savedT = 0.0;
    for (final g in d.goals) {
      for (final c in g.contribs) {
        if (c.date.inMonth(y, m)) savedT += c.amount;
      }
    }
    final now = DateTime.now();
    final dim = daysInMonth(y, m);
    final el = (now.year == y && now.month == m) ? now.day : dim;
    return MonthStats(
      year: y,
      month: m,
      inT: inT,
      outT: outT,
      savedT: savedT,
      byCat: byCat,
      budget: st.budget,
      daysElapsed: el,
      daysInMonth: dim,
    );
  }

  MonthStats get curStats => statsFor(DateTime.now().year, DateTime.now().month);

  MonthStats prevStatsOf(MonthStats s) {
    final p = DateTime(s.year, s.month - 1, 1);
    return statsFor(p.year, p.month);
  }

  List<Tx> get txsSorted {
    final list = [...d.txs]..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double avgMonthlySaving() {
    if (d.goals.isEmpty) return 0;
    final months = <String>{};
    for (final g in d.goals) {
      for (final c in g.contribs) {
        months.add('${c.date.year}-${c.date.month}');
      }
    }
    final totalSavedAll = d.totalSaved;
    if (months.isEmpty || totalSavedAll <= 0) return 0;
    return totalSavedAll / max(months.length, 1);
  }

  bool goalOnTrack(Goal g) {
    if (g.done) return true;
    if (g.deadline == null) return true;
    final req = reqMonthly(g.remaining, g.deadline!);
    if (req <= 0) return true;
    final cap = max(avgMonthlySaving(), curStats.savedT);
    return cap >= req * 0.8;
  }

  ReportSnap? reportFor(int y, int m, {bool cache = true}) {
    final key = '$y-${m.toString().padLeft(2, '0')}';
    for (final r in d.reports) {
      if (r.key == key) return r;
    }
    final s = statsFor(y, m);
    final hasData = s.inT > 0 || s.outT > 0 || s.savedT > 0;
    if (!hasData) return null;
    final prev = prevStatsOf(s);
    String improved = '';
    double bestDelta = 0;
    for (final e in s.byCat.entries) {
      final pv = prev.byCat[e.key] ?? 0;
      final delta = pv - e.value;
      if (delta > bestDelta) {
        bestDelta = delta;
        improved = e.key;
      }
    }
    final goalsAvg =
        d.goals.isEmpty ? 0.0 : d.goals.fold(0.0, (a, g) => a + g.pct) / d.goals.length;
    String top = '';
    double topV = -1;
    s.byCat.forEach((k, v) {
      if (v > topV) {
        topV = v;
        top = k;
      }
    });
    final snap = ReportSnap(
      key: key,
      inT: s.inT,
      outT: s.outT,
      savedT: s.savedT,
      savePct: s.savedPct,
      budgetUsedPct: s.pctUsed,
      goalsAvgPct: goalsAvg,
      topCat: top,
      improvedCat: improved,
    );
    if (cache && !s.isCurrent) {
      d.reports.add(snap);
      persist();
    }
    return snap;
  }

  void ensurePrevReport() {
    final n = DateTime.now();
    final pm = DateTime(n.year, n.month - 1, 1);
    reportFor(pm.year, pm.month);
  }

  Set<String> computeUnlocked() {
    final u = <String>{};
    if (d.txs.isNotEmpty) u.add('first');
    if (streakDays(d.txs.map((t) => t.date).toList()) >= 7) u.add('streak7');
    if (d.totalSaved >= 5000) u.add('fivek');

    final underMonths = <String>[];
    final seen = <String>{};
    for (final t in d.txs) {
      seen.add('${t.date.year}-${t.date.month.toString().padLeft(2, '0')}');
    }
    final now = DateTime.now();
    for (final k in seen) {
      final parts = k.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (y == now.year && m == now.month) continue;
      if (st.budget <= 0) break;
      final s = statsFor(y, m);
      if (s.outT <= st.budget && s.outT > 0) underMonths.add(k);
    }
    if (underMonths.isNotEmpty) u.add('under');
    if (_consecutiveUnder(underMonths) >= 3) u.add('master');

    if (d.goals.any((g) => g.done)) u.add('crusher');
    if (d.reports.isNotEmpty) u.add('month1');
    return u;
  }

  int _consecutiveUnder(List<String> months) {
    if (months.isEmpty) return 0;
    final set = months.toSet();
    final sorted = months.toList()
      ..sort((a, b) => b.compareTo(a));
    var best = 0;
    for (final start in sorted) {
      final p = start.split('-');
      var y = int.parse(p[0]);
      var m = int.parse(p[1]);
      var run = 0;
      while (set.contains('$y-${m.toString().padLeft(2, '0')}')) {
        run++;
        m--;
        if (m == 0) {
          m = 12;
          y--;
        }
      }
      if (run > best) best = run;
    }
    return best;
  }

  int get streak => streakDays(d.txs.map((t) => t.date).toList());

  void checkAchievements({required bool silent}) {
    final unlocked = computeUnlocked();
    fresh.clear();
    for (final id in unlocked) {
      if (!d.achv.contains(id)) {
        d.achv.add(id);
        fresh.add(id);
      }
    }
    if (fresh.isNotEmpty) {
      persist();
      notifyListeners();
      if (!silent && st.nAchv) {
        final ll = L(st.lang);
        for (var i = 0; i < fresh.length; i++) {
          _notif.show(
            200 + i,
            'SaveWise',
            ll.msg(MsgType.badge, st.personality, {'badge': fresh[i]}),
          );
        }
      }
    }
  }

  void addTx(Tx t) {
    d.txs.add(t);
    bump();
  }

  void updateTx(Tx t) {
    final i = d.txs.indexWhere((x) => x.id == t.id);
    if (i >= 0) d.txs[i] = t;
    bump();
  }

  void deleteTx(String id) {
    d.txs.removeWhere((t) => t.id == id);
    bump();
  }

  Goal? goalById(String id) {
    for (final g in d.goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  void addGoal(Goal g) {
    d.goals.add(g);
    bump();
  }

  void updateGoal(Goal g) {
    final i = d.goals.indexWhere((x) => x.id == g.id);
    if (i >= 0) d.goals[i] = g;
    bump();
  }

  void deleteGoal(String id) {
    d.goals.removeWhere((g) => g.id == id);
    bump();
  }

  void contribute(String id, double amt) {
    final g = goalById(id);
    if (g == null || amt <= 0) return;
    g.contribs.add(Contrib(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      amount: amt,
      date: DateTime.now(),
    ));
    g.saved += amt;
    bump();
  }

  void importCsvMerge(List<Tx> incoming) {
    final ids = d.txs.map((t) => t.id).toSet();
    for (final t in incoming) {
      if (ids.add(t.id)) d.txs.add(t);
    }
    bump();
  }

  String fmt(num v) => money(v, sym);
}
