import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import 'widgets/common.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final now = DateTime.now();
    final items = <Widget>[];

    for (var i = 0; i < 12; i++) {
      final dt = DateTime(now.year, now.month - i, 1);
      final isCurrent = dt.year == now.year && dt.month == now.month;
      if (isCurrent) continue;
      final snap = store.reportFor(dt.year, dt.month);
      if (snap == null) continue;
      items.add(_ReportTile(snap: snap, y: dt.year, m: dt.month));
      items.add(const SizedBox(height: 12));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.t('repTitle'))),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          _LivePreview(store: store),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: EmptyState(
                icon: Icons.description_outlined,
                title: l.t('repTitle'),
                sub: l.t('noRepYet'),
              ),
            )
          else
            ...items,
        ],
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final now = DateTime.now();
    final s = store.curStats;
    return SoftCard(
      pad: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.t('repFor').replaceAll('{m}', l.monthName(now.month)).replaceAll('{y}', '${now.year}'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: C.green.withOpacity(.13), borderRadius: BorderRadius.circular(20)),
                child: Text(l.t('liveNow'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: C.green)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _kv(context, l.t('inL'), money(s.inT, store.sym), C.green)),
              Expanded(child: _kv(context, l.t('outL'), money(s.outT, store.sym), C.red)),
              Expanded(child: _kv(context, l.t('savedL'), money(s.savedT, store.sym), C.violet)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext ctx, String k, String v, Color c) {
    return Column(
      children: [
        Text(v, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: c)),
        Text(k, style: Theme.of(ctx).textTheme.bodySmall!.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _ReportTile extends StatefulWidget {
  const _ReportTile({required this.snap, required this.y, required this.m});
  final dynamic snap;
  final int y;
  final int m;

  @override
  State<_ReportTile> createState() => __ReportTileState();
}

class __ReportTileState extends State<_ReportTile> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final r = widget.snap;
    final sym = store.sym;

    String topCat = '';
    if ((r.topCat as String).isNotEmpty) {
      topCat = l.cat(r.topCat as String);
    }
    String improved = '';
    if ((r.improvedCat as String).isNotEmpty) {
      improved = l.cat(r.improvedCat as String);
    }

    return SoftCard(
      pad: 18,
      onTap: () => setState(() => open = !open),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [C.green.withOpacity(.2), C.violet.withOpacity(.15)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.description_rounded, color: C.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.t('repFor').replaceAll('{m}', l.monthName(widget.m)).replaceAll('{y}', '${widget.y}'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              AnimatedRotation(
                turns: open ? .5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kv(context, l.t('inL'), money(r.inT, sym), C.green)),
              Expanded(child: _kv(context, l.t('outL'), money(r.outT, sym), C.red)),
              Expanded(child: _kv(context, l.t('savedL'), money(r.savedT, sym), C.violet)),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Divider(color: Theme.of(context).dividerTheme.color),
                const SizedBox(height: 8),
                _line(context, Icons.restaurant_menu_rounded, l.t('bigEater'),
                    topCat.isEmpty ? '—' : topCat),
                if (improved.isNotEmpty)
                  _line(context, Icons.trending_down_rounded, l.t('mostImp'), improved),
                _line(context, Icons.percent_rounded, l.t('saveRate'), '${r.savePct.round()}%'),
                if ((store.st.budget) > 0)
                  _line(context, Icons.speed_rounded, l.t('budPerf'), '${r.budgetUsedPct.round()}%'),
                if ((r.goalsAvgPct as double) > 0)
                  _line(context, Icons.flag_rounded, l.t('goalsProg'), '${r.goalsAvgPct.round()}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext ctx, String k, String v, Color c) {
    return Column(
      children: [
        Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: c)),
        Text(k, style: Theme.of(ctx).textTheme.bodySmall!.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _line(BuildContext ctx, IconData i, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(i, size: 16, color: Theme.of(ctx).textTheme.bodySmall!.color),
          const SizedBox(width: 9),
          Expanded(child: Text(k, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text(v, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
