import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/calc.dart';
import '../core/cats.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import 'widgets/common.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late int y;
  late int m;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    y = n.year;
    m = n.month;
  }

  void shift(int delta) {
    var d = DateTime(y, m + delta, 1);
    setState(() {
      y = d.year;
      m = d.month;
    });
  }

  bool canGoNext() {
    final n = DateTime.now();
    return DateTime(y, m).isBefore(DateTime(n.year, n.month));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final s = store.statsFor(y, m);
    final prev = DateTime(y, m - 1, 1);
    final p = store.statsFor(prev.year, prev.month);
    final l = L.of(context);

    if (s.inT == 0 && s.outT == 0) {
      return Scaffold(
        appBar: AppBar(title: Text(l.t('analysis'))),
        body: EmptyState(
          icon: Icons.donut_large_rounded,
          title: l.t('noDataT'),
          sub: l.t('noDataS'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('analysis')),
        actions: [
          IconButton(onPressed: () => shift(-1), icon: const Icon(Icons.chevron_left_rounded)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                '${l.monthName(m)} ${y.toString().substring(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
          IconButton(
            onPressed: canGoNext() ? () => shift(1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: l.t('inL'),
                  value: money(s.inT, store.sym),
                  icon: Icons.south_west_rounded,
                  color: C.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: l.t('outL'),
                  value: money(s.outT, store.sym),
                  icon: Icons.north_east_rounded,
                  color: C.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatTile(
            label: l.t('savedL'),
            value: money(s.savedT, store.sym),
            icon: Icons.savings_rounded,
            color: C.violet,
          ),
          const SizedBox(height: 18),

          SectionHead(l.t('breakdown')),
          SoftCard(
            pad: 20,
            child: Column(
              children: [
                if (s.outT > 0) ...[
                  SizedBox(
                    height: 190,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 46,
                        startDegreeOffset: -90,
                        sections: _sections(s),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ..._legend(context, s, store),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(l.t('noDataS'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          SectionHead(l.t('trends')),
          SoftCard(
            pad: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _dot(C.green, l.t('inL')),
                    const SizedBox(width: 14),
                    _dot(C.red, l.t('outL')),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(height: 170, child: _bars(store)),
              ],
            ),
          ),
          const SizedBox(height: 18),

          SectionHead(l.t('compare')),
          SoftCard(
            pad: 6,
            child: Column(children: _compareRows(s, p, l)),
          ),
          const SizedBox(height: 18),

          SectionHead('Insights'),
          ..._insights(s, p, l).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SoftCard(
                  pad: 14,
                  radius: 18,
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 17, color: C.amber),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _dot(Color c, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  List<PieChartSectionData> _sections(dynamic s) {
    final entries = (s.byCat as Map<String, double>).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = s.outT as double;
    final list = <PieChartSectionData>[];
    for (var i = 0; i < entries.length && i < 7; i++) {
      final e = entries[i];
      final col = catColor(e.key);
      list.add(PieChartSectionData(
        value: e.value,
        color: col,
        radius: 34 + (i == 0 ? 10 : 0),
        title: '${pctOf(e.value, total).round()}%',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
      ));
    }
    if (entries.length > 7) {
      final rest = entries.sublist(7).fold(0.0, (a, e) => a + e.value);
      list.add(PieChartSectionData(
        value: rest,
        color: C.subLight.withOpacity(.5),
        radius: 34,
        title: '',
      ));
    }
    return list;
  }

  List<Widget> _legend(BuildContext ctx, dynamic s, Store store) {
    final l = L.of(ctx);
    final entries = (s.byCat as Map<String, double>).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = s.outT as double;
    return entries.take(6).map((e) {
      final pct = pctOf(e.value, total);
      return Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            Icon(catIcon(e.key), size: 15, color: catColor(e.key)),
            const SizedBox(width: 8),
            Expanded(child: Text(l.cat(e.key), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Text(
              '${money(e.value, store.sym)}  ·  ${pct.round()}%',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Theme.of(ctx).textTheme.bodySmall!.color),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _bars(Store store) {
    final now = DateTime.now();
    final data = <(String, double, double)>[];
    for (var i = 5; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      final s = store.statsFor(dt.year, dt.month);
      data.add((L.of(context).monthName(dt.month).substring(0, 3), s.inT, s.outT));
    }
    final maxV = data.fold<double>(0, (a, e) => math.max(math.max(a, e.$2), e.$3)) * 1.15;
    final grid = Theme.of(context).dividerTheme.color;
    return BarChart(
      BarChartData(
        maxY: maxV <= 0 ? 100 : maxV,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(color: grid ?? Colors.grey.shade300, strokeWidth: 1, dashArray: [4]),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  data[v.toInt()].$1,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodySmall!.color),
                ),
              ),
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          final d = data[i];
          return BarChartGroupData(
            x: i,
            barsSpace: 5,
            barRods: [
              BarChartRodData(
                toY: d.$2,
                color: C.green,
                width: 11,
                borderRadius: BorderRadius.circular(6),
              ),
              BarChartRodData(
                toY: d.$3,
                color: C.red.withOpacity(.85),
                width: 11,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _compareRows(dynamic s, dynamic p, L l) {
    final cur = (s.byCat as Map<String, double>);
    final prv = (p.byCat as Map<String, double>);
    final keys = {...cur.keys, ...prv.keys}.toList()
      ..sort((a, b) => (cur[b] ?? 0).compareTo(cur[a] ?? 0));
    if (keys.isEmpty) {
      return [
        Padding(padding: const EdgeInsets.all(14), child: Text(l.t('noDataS'), style: Theme.of(context).textTheme.bodySmall))
      ];
    }
    return keys.take(5).map((k) {
      final cv = cur[k] ?? 0;
      final pv = prv[k] ?? 0;
      final delta = cv - pv;
      final up = delta > 0;
      final col = delta == 0 ? C.subLight : (up ? C.red : C.green);
      return ListTile(
        dense: true,
        leading: Icon(catIcon(k), size: 19, color: catColor(k)),
        title: Text(l.cat(k), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${l.t('prev')}: ${money(pv, context.read<Store>().sym)}',
          style: const TextStyle(fontSize: 11.5),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: col.withOpacity(.13), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: col),
              const SizedBox(width: 3),
              Text(money(delta.abs(), context.read<Store>().sym), style: TextStyle(fontSize: 11.5, fontWeight: w800b, color: col)),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<String> _insights(dynamic s, dynamic p, L l) {
    final out = <String>[];
    final cur = (s.byCat as Map<String, double>);
    if (cur.isNotEmpty) {
      final top = cur.entries.reduce((a, b) => a.value > b.value ? a : b);
      out.add(l.t('topCat').replaceAll('{cat}', l.cat(top.key)));
    }
    if ((s.inT as double) > 0) {
      out.add(l.t('keptPct').replaceAll('{pct}', '${(s.savedPct as double).round()}'));
    }
    String? biggestUp;
    double bestDelta = 0;
    for (final e in cur.entries) {
      final d = e.value - ((p.byCat as Map<String, double>)[e.key] ?? 0);
      if (d > bestDelta) {
        bestDelta = d;
        biggestUp = e.key;
      }
    }
    if (biggestUp != null && bestDelta > 0) {
      out.add(l.t('bigJumpUp').replaceAll('{cat}', l.cat(biggestUp)).replaceAll('{v}', '+${money(bestDelta, context.read<Store>().sym)}'));
    }
    return out;
  }
}

const w800b = FontWeight.w800;
