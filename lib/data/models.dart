import 'dart:math';

enum Kind { credit, debit }

Kind kindOf(String s) => s == 'credit' ? Kind.credit : Kind.debit;

class Tx {
  String id;
  Kind kind;
  double amount;
  String key;
  String note;
  DateTime date;
  bool recurring;

  Tx({
    required this.id,
    required this.kind,
    required this.amount,
    required this.key,
    this.note = '',
    required this.date,
    this.recurring = false,
  });

  factory Tx.fromJson(Map<String, dynamic> j) => Tx(
        id: j['id'] as String? ?? '',
        kind: kindOf(j['kind'] as String? ?? 'debit'),
        amount: (j['amount'] as num? ?? 0).toDouble(),
        key: j['key'] as String? ?? 'other',
        note: j['note'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        recurring: j['recurring'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'amount': amount,
        'key': key,
        'note': note,
        'date': date.toIso8601String(),
        'recurring': recurring,
      };
}

class Contrib {
  String id;
  double amount;
  DateTime date;

  Contrib({required this.id, required this.amount, required this.date});

  factory Contrib.fromJson(Map<String, dynamic> j) => Contrib(
        id: j['id'] as String? ?? '',
        amount: (j['amount'] as num? ?? 0).toDouble(),
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'amount': amount, 'date': date.toIso8601String()};
}

class Goal {
  String id;
  String name;
  String icon;
  double target;
  double saved;
  DateTime? deadline;
  List<Contrib> contribs;

  Goal({
    required this.id,
    required this.name,
    required this.target,
    this.icon = '🎯',
    this.saved = 0,
    this.deadline,
    List<Contrib>? contribs,
  }) : contribs = contribs ?? [];

  double get pct => target <= 0 ? 0 : (saved / target * 100).clamp(0, 100).toDouble();
  double get remaining => max(0, target - saved);
  bool get done => target > 0 && saved >= target;

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        icon: j['icon'] as String? ?? '🎯',
        target: (j['target'] as num? ?? 0).toDouble(),
        saved: (j['saved'] as num? ?? 0).toDouble(),
        deadline: j['deadline'] == null
            ? null
            : DateTime.tryParse(j['deadline'] as String),
        contribs: ((j['contribs'] as List?) ?? [])
            .map((c) => Contrib.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'target': target,
        'saved': saved,
        'deadline': deadline?.toIso8601String(),
        'contribs': contribs.map((c) => c.toJson()).toList(),
      };
}

class ReportSnap {
  String key;
  double inT;
  double outT;
  double savedT;
  double savePct;
  double budgetUsedPct;
  double goalsAvgPct;
  String topCat;
  String improvedCat;

  ReportSnap({
    required this.key,
    required this.inT,
    required this.outT,
    required this.savedT,
    required this.savePct,
    required this.budgetUsedPct,
    required this.goalsAvgPct,
    required this.topCat,
    required this.improvedCat,
  });

  factory ReportSnap.fromJson(Map<String, dynamic> j) => ReportSnap(
        key: j['key'] as String? ?? '',
        inT: (j['inT'] as num? ?? 0).toDouble(),
        outT: (j['outT'] as num? ?? 0).toDouble(),
        savedT: (j['savedT'] as num? ?? 0).toDouble(),
        savePct: (j['savePct'] as num? ?? 0).toDouble(),
        budgetUsedPct: (j['budgetUsedPct'] as num? ?? 0).toDouble(),
        goalsAvgPct: (j['goalsAvgPct'] as num? ?? 0).toDouble(),
        topCat: j['topCat'] as String? ?? '',
        improvedCat: j['improvedCat'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'inT': inT,
        'outT': outT,
        'savedT': savedT,
        'savePct': savePct,
        'budgetUsedPct': budgetUsedPct,
        'goalsAvgPct': goalsAvgPct,
        'topCat': topCat,
        'improvedCat': improvedCat,
      };
}

class Settings {
  Settings();

  String lang = 'en';
  String theme = 'system';
  String name = '';
  double budget = 0;
  String currency = 'INR';
  String personality = 'normal';
  int threshold = 70;
  bool nDaily = true;
  bool nBudget = true;
  bool nGoal = true;
  bool nSummary = true;
  bool nRecurring = false;
  bool nAchv = true;
  String dailyTime = '20:00';
  bool onboarded = false;

  factory Settings.fromJson(Map<String, dynamic> j) {
    final s = Settings();
    s.lang = j['lang'] as String? ?? 'en';
    s.theme = j['theme'] as String? ?? 'system';
    s.name = j['name'] as String? ?? '';
    s.budget = (j['budget'] as num? ?? 0).toDouble();
    s.currency = j['currency'] as String? ?? 'INR';
    s.personality = j['personality'] as String? ?? 'normal';
    s.threshold = (j['threshold'] as num? ?? 70).toInt();
    s.nDaily = j['nDaily'] as bool? ?? true;
    s.nBudget = j['nBudget'] as bool? ?? true;
    s.nGoal = j['nGoal'] as bool? ?? true;
    s.nSummary = j['nSummary'] as bool? ?? true;
    s.nRecurring = j['nRecurring'] as bool? ?? false;
    s.nAchv = j['nAchv'] as bool? ?? true;
    s.dailyTime = j['dailyTime'] as String? ?? '20:00';
    s.onboarded = j['onboarded'] as bool? ?? false;
    return s;
  }

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'theme': theme,
        'name': name,
        'budget': budget,
        'currency': currency,
        'personality': personality,
        'threshold': threshold,
        'nDaily': nDaily,
        'nBudget': nBudget,
        'nGoal': nGoal,
        'nSummary': nSummary,
        'nRecurring': nRecurring,
        'nAchv': nAchv,
        'dailyTime': dailyTime,
        'onboarded': onboarded,
      };
}

class AppData {
  List<Tx> txs = [];
  List<Goal> goals = [];
  List<ReportSnap> reports = [];
  Set<String> achv = {};
  Settings st = Settings();

  AppData();

  factory AppData.fromJson(Map<String, dynamic> j) {
    final d = AppData();
    d.txs = ((j['txs'] as List?) ?? [])
        .map((t) => Tx.fromJson(t as Map<String, dynamic>))
        .toList();
    d.goals = ((j['goals'] as List?) ?? [])
        .map((g) => Goal.fromJson(g as Map<String, dynamic>))
        .toList();
    d.reports = ((j['reports'] as List?) ?? [])
        .map((r) => ReportSnap.fromJson(r as Map<String, dynamic>))
        .toList();
    d.achv = Set<String>.from(j['achv'] as List? ?? []);
    d.st = Settings.fromJson(j['st'] as Map<String, dynamic>? ?? {});
    return d;
  }

  Map<String, dynamic> toJson() => {
        'txs': txs.map((t) => t.toJson()).toList(),
        'goals': goals.map((g) => g.toJson()).toList(),
        'reports': reports.map((r) => r.toJson()).toList(),
        'achv': achv.toList(),
        'st': st.toJson(),
      };

  double get totalSaved => goals.fold(0, (a, g) => a + g.saved);
}

class MonthStats {
  final int year;
  final int month;
  final double inT;
  final double outT;
  final double savedT;
  final Map<String, double> byCat;
  final double budget;
  final int daysElapsed;
  final int daysInMonth;

  MonthStats({
    required this.year,
    required this.month,
    required this.inT,
    required this.outT,
    required this.savedT,
    required this.byCat,
    required this.budget,
    required this.daysElapsed,
    required this.daysInMonth,
  });

  double get pace => daysElapsed <= 0 ? 0 : outT / daysElapsed;
  double get projected => pace * daysInMonth;
  double get pctUsed => budget <= 0 ? 0 : (outT / budget * 100).clamp(0, 999).toDouble();
  double get available => inT - outT;
  double get overProj => max(0, projected - budget);
  double get savedPct => inT <= 0 ? 0 : (savedT / inT * 100).clamp(0, 100).toDouble();
  bool get isCurrent {
    final n = DateTime.now();
    return n.year == year && n.month == month;
  }
}

const symbols = {'INR': '₹', 'USD': '\$', 'EUR': '€'};
