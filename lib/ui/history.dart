import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/cats.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import 'add_tx_sheet.dart';
import 'widgets/common.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String kindF = 'all';
  String? catF;
  DateTimeRange? range;
  String query = '';
  final searchC = TextEditingController();
  bool searching = false;

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final all = store.txsSorted.where((t) {
      if (kindF == 'in' && t.kind != Kind.credit) return false;
      if (kindF == 'out' && t.kind != Kind.debit) return false;
      if (catF != null && t.key != catF) return false;
      if (range != null) {
        if (t.date.isBefore(range!.start.dayOnly)) return false;
        if (t.date.isAfter(range!.end.dayOnly.add(const Duration(days: 1)))) return false;
      }
      if (query.isNotEmpty) {
        final label = t.kind == Kind.credit ? l.src(t.key) : l.cat(t.key);
        final q = query.toLowerCase();
        if (!label.toLowerCase().contains(q) && !t.note.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    final groups = <DateTime, List<Tx>>{};
    for (final t in all) {
      groups.putIfAbsent(t.date.dayOnly, () => []).add(t);
    }

    final activeF = kindF != 'all' || catF != null || range != null;

    return Scaffold(
      appBar: AppBar(
        title: searching
            ? TextField(
                controller: searchC,
                autofocus: true,
                decoration: InputDecoration(hintText: l.t('searchTx'), filled: true),
                onChanged: (v) => setState(() => query = v),
              )
            : Text(l.t('history')),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              searching = !searching;
              query = '';
              searchC.clear();
            }),
            icon: Icon(searching ? Icons.close_rounded : Icons.search_rounded),
          ),
          IconButton(
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: activeF,
              smallSize: 8,
              backgroundColor: C.green,
              child: const Icon(Icons.filter_list_rounded),
            ),
          ),
        ],
      ),
      body: all.isEmpty
          ? EmptyState(
              icon: Icons.auto_stories_rounded,
              title: l.t('emptyTxT'),
              sub: l.t('emptyTxS'),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
              itemCount: groups.length,
              itemBuilder: (ctx, i) {
                final day = groups.keys.elementAt(i);
                final list = groups[day]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 14, bottom: 8),
                      child: Row(
                        children: [
                          Text(dayLabel(l, day), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                          const SizedBox(width: 10),
                          Expanded(child: Divider(color: Theme.of(context).dividerTheme.color)),
                        ],
                      ),
                    ),
                    ...list.map((t) => TxTile(
                          tx: t,
                          sym: store.sym,
                          onEdit: () => showSheet(context, builder: (_) => AddTxSheet(existing: t)),
                          onDelete: () {
                            store.deleteTx(t.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.t('deleted'))));
                          },
                        )),
                  ],
                );
              },
            ),
    );
  }

  void _openFilters() async {
    final l = L.of(context);
    var k = kindF;
    var c = catF;
    var r = range;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.t('filters'), style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'all', label: Text(l.t('fAll'))),
                    ButtonSegment(value: 'in', label: Text(l.t('fIn'))),
                    ButtonSegment(value: 'out', label: Text(l.t('fOut'))),
                  ],
                  selected: {k},
                  onSelectionChanged: (s) => setM(() => k = s.first),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(l.t('fAll')),
                          selected: c == null,
                          onSelected: (_) => setM(() => c = null),
                          selectedColor: C.green.withOpacity(.18),
                        ),
                      ),
                      ...catKeys.map((ck) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(catIcon(ck), size: 15, color: catColor(ck)),
                              label: Text(l.cat(ck)),
                              selected: c == ck,
                              onSelected: (_) => setM(() => c = ck),
                              selectedColor: catColor(ck).withOpacity(.18),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r == null
                            ? l.t('rangePick')
                            : '${shortDate(r!.start)} – ${shortDate(r!.end)}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDateRangePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate: now.add(const Duration(days: 1)),
                          initialDateRange: r,
                        );
                        if (picked != null) setM(() => r = picked);
                      },
                      child: Text(l.t('rangePick')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            kindF = 'all';
                            catF = null;
                            range = null;
                          });
                        },
                        child: Text(l.t('clearF')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            kindF = k;
                            catF = c;
                            range = r;
                          });
                        },
                        child: Text(l.t('done')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void openHistory(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
}
