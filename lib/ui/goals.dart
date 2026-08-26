import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/calc.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import 'widgets/common.dart';

const goalEmojis = ['🎯', '📱', '✈️', '🏠', '🎓', '💍', '🚗', '💻'];

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final goals = [...store.d.goals]..sort((a, b) => b.pct.compareTo(a.pct));

    return Scaffold(
      appBar: AppBar(title: Text(l.t('goalsT'))),
      body: goals.isEmpty
          ? EmptyState(
              icon: Icons.flag_rounded,
              title: l.t('emptyGoalT'),
              sub: l.t('emptyGoalS'),
              cta: l.t('newGoal'),
              onCta: () => openGoalEditor(context),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
              children: [
                SoftCard(
                  pad: 18,
                  child: Row(
                    children: [
                      const IconBubble(Icons.savings_rounded, color: C.violet, soft: C.violetSoft),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(money(store.d.totalSaved, store.sym),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -.4)),
                          Text(l.t('totalSaved'), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...goals.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(goal: g),
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openGoalEditor(context),
        backgroundColor: C.violet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(L.of(context).t('newGoal')),
      ),
    );
  }
}

void openGoals(BuildContext context) {
  Navigator.of(context, rootNavigator: false).push(MaterialPageRoute(builder: (_) => const GoalsPage()));
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final g = goal;
    final onTrack = store.goalOnTrack(g);

    late final String statusL;
    late final Color sc;
    if (g.done) {
      statusL = l.t('achieved');
      sc = C.green;
    } else if (onTrack) {
      statusL = l.t('onTrack');
      sc = C.blue;
    } else {
      statusL = l.t('behind');
      sc = C.amber;
    }

    final req = g.deadline != null && !g.done ? reqMonthly(g.remaining, g.deadline!) : 0.0;

    return SoftCard(
      pad: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: C.violetSoft.withOpacity(.6), borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: Text(g.icon, style: const TextStyle(fontSize: 21)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, letterSpacing: -.3)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.event_rounded, size: 11.5, color: Theme.of(context).textTheme.bodySmall!.color),
                        const SizedBox(width: 4),
                        Text(
                          g.deadline == null
                              ? l.t('noDeadlineChip')
                              : shortDate(g.deadline!),
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                splashRadius: 20,
                iconSize: 20,
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'a', child: Row(children: [const Icon(Icons.add_card_rounded, size: 17), const SizedBox(width: 8), Text(l.t('addMoney'))])),
                  PopupMenuItem(value: 'e', child: Row(children: [const Icon(Icons.edit_rounded, size: 17), const SizedBox(width: 8), Text(l.t('edit'))])),
                  PopupMenuItem(value: 'd', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 17, color: C.red), const SizedBox(width: 8), Text(l.t('delete'), style: const TextStyle(color: C.red))])),
                ],
                onSelected: (v) {
                  if (v == 'a') _contributeSheet(context, g.id);
                  if (v == 'e') openGoalEditor(context, existing: g);
                  if (v == 'd') _deleteGoal(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(g.saved, store.sym),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -.4)),
              Text(' / ${money(g.target, store.sym)}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: sc.withOpacity(.13), borderRadius: BorderRadius.circular(10)),
                child: Text(statusL, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: sc)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Bar(g.pct / 100, color: C.violet),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${g.pct.round()}%',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: C.violet),
              ),
              const Spacer(),
              if (req > 0)
                Text(
                  l.t('reqMo').replaceAll('{v}', money(req, store.sym)),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteGoal(BuildContext context) {
    final l = L.of(context);
    showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.t('delGoalQ')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.red, minimumSize: const Size(0, 44)),
            onPressed: () {
              context.read<Store>().deleteGoal(goal.id);
              Navigator.pop(d, true);
            },
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
  }

  void _contributeSheet(BuildContext context, String id) {
    showSheet(context, builder: (_) => _ContributeSheet(id: id));
  }
}

void openGoalEditor(BuildContext context, {Goal? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _GoalEditor(existing: existing),
    ),
  );
}

class _GoalEditor extends StatefulWidget {
  const _GoalEditor({this.existing});
  final Goal? existing;

  @override
  State<_GoalEditor> createState() => __GoalEditorState();
}

class __GoalEditorState extends State<_GoalEditor> {
  late TextEditingController nameC;
  late TextEditingController targetC;
  DateTime? deadline;
  late String emoji;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.existing?.name ?? '');
    targetC = TextEditingController(
        text: widget.existing == null || widget.existing!.target == 0 ? '' : widget.existing!.target.toStringAsFixed(0));
    deadline = widget.existing?.deadline;
    emoji = widget.existing?.icon ?? goalEmojis.first;
  }

  @override
  void dispose() {
    nameC.dispose();
    targetC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? l.t('newGoal') : l.t('edit'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: goalEmojis.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final e = goalEmojis[i];
                  final sel = e == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => emoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 52,
                      decoration: BoxDecoration(
                        color: sel ? C.violetSoft : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: sel ? C.violet : Colors.transparent, width: 1.6),
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 23)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameC,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l.t('goalName')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetC,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: l.t('target'),
                prefixText: ' ${context.read<Store>().sym} ',
                prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.violet),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: deadline ?? DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (d != null) setState(() => deadline = d);
              },
              child: InputDecorator(
                decoration: InputDecoration(hintText: l.t('deadline')),
                child: Text(deadline == null ? l.t('noneL') : shortDate(deadline!),
                    style: const TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: C.violet),
              onPressed: () {
                final t = double.tryParse(targetC.text.trim()) ?? 0;
                if (nameC.text.trim().isEmpty || t <= 0) return;
                final store = context.read<Store>();
                if (widget.existing == null) {
                  store.addGoal(Goal(
                    id: 'g${DateTime.now().microsecondsSinceEpoch}',
                    name: nameC.text.trim(),
                    icon: emoji,
                    target: t,
                    deadline: deadline,
                  ));
                } else {
                  final g = widget.existing!;
                  g.name = nameC.text.trim();
                  g.icon = emoji;
                  g.target = t;
                  g.deadline = deadline;
                  store.updateGoal(g);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.t('goalSaved'))));
              },
              child: Text(l.t('save')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributeSheet extends StatefulWidget {
  const _ContributeSheet({required this.id});
  final String id;

  @override
  State<_ContributeSheet> createState() => __ContributeSheetState();
}

class __ContributeSheetState extends State<_ContributeSheet> {
  final c = TextEditingController();
  double quick = 0;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final g = store.goalById(widget.id);
    if (g == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(g.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Text(g.name, style: Theme.of(context).textTheme.titleLarge)),
              Text('${g.pct.round()}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: C.violet)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [100, 500, 1000].map((v) {
              final sel = quick == v.toDouble();
              return ChoiceChip(
                label: Text(money(v.toDouble(), store.sym)),
                selected: sel,
                onSelected: (_) {
                  setState(() {
                    quick = v.toDouble();
                    c.clear();
                  });
                },
                selectedColor: C.violetSoft,
                labelStyle: TextStyle(fontWeight: FontWeight.w700, color: sel ? C.violet : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => setState(() => quick = 0),
            decoration: InputDecoration(
              hintText: l.t('custom'),
              prefixText: ' ${store.sym} ',
              prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.violet),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.violet),
            onPressed: () {
              final amt = quick > 0 ? quick : (double.tryParse(c.text.trim()) ?? 0);
              if (amt <= 0) return;
              store.contribute(g.id, amt);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.t('contributed'))));
            },
            child: Text(l.t('addMoney')),
          ),
        ],
      ),
    );
  }
}
