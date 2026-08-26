import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/calc.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import 'achievements_page.dart';
import 'budget_page.dart';
import 'history.dart';
import 'goals.dart';
import 'reports.dart';
import 'settings.dart';
import 'widgets/common.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.onTab});

  final void Function(String tab) onTab;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final s = store.curStats;
    final prev = store.prevStatsOf(s);
    final l = L.of(context);
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? C.textDark : C.textLight;

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.greeting(now.hour)}${store.st.name.isEmpty ? '' : ', ${store.st.name}'}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -.5, color: fg),
                    ),
                    Text(l.t('thisMonth'), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsPage()),
                ),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.emoji_events_rounded, color: fg.withOpacity(.75)),
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(color: C.amber, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).scaffoldBackgroundColor)),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
                icon: Icon(Icons.settings_outlined, color: fg.withOpacity(.75)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _HeroCard(store: store, s: s),
          const SizedBox(height: 16),

          if (s.budget > 0)
            _BudgetCard(store: store, s: s)
          else
            SoftCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetPage())),
              child: Row(
                children: [
                  const IconBubble(Icons.speed_rounded, color: C.blue, soft: C.blueSoft),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.t('noBudgetT'), style: const TextStyle(fontWeight: w800, fontSize: 15)),
                        Text(l.t('noBudgetS'), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetPage())),
                    child: Text(l.t('setNow'), style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          _Alerts(s: s, prev: prev, store: store),
          const SizedBox(height: 4),

          _ActiveGoal(store: store),
          const SizedBox(height: 18),

          SectionHead(l.t('recent'), action: l.t('viewAll'), onAction: () {
            openHistory(context);
          }),
          ...store.txsSorted.take(3).map((t) => TxTile(tx: t, sym: store.sym)),
          if (store.d.txs.isEmpty)
            SoftCard(
              pad: 22,
              child: Center(
                child: Text(
                  l.t('emptyTxT'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _quickTile(context, Icons.receipt_long_rounded, l.t('reports'), () {
                  Navigator.push(context, MaterialPageRoute(builder: (d1) => const ReportsPage()));
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickTile(context, Icons.emoji_events_rounded, l.t('achievements'), () {
                  Navigator.push(context, MaterialPageRoute(builder: (d2) => const AchievementsPage()));
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickTile(BuildContext ctx, IconData i, String label, VoidCallback onTap) {
    return SoftCard(
      pad: 16,
      radius: 20,
      onTap: onTap,
      child: Row(
        children: [
          Icon(i, size: 21, color: C.green),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: w700, fontSize: 13.5))),
          const Icon(Icons.chevron_right_rounded, size: 17),
        ],
      ),
    );
  }
}

const w700 = FontWeight.w700;
const w800 = FontWeight.w800;

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.store, required this.s});
  final Store store;
  final dynamic s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34D399), C.green, Color(0xFF047857)],
        ),
        boxShadow: [
          BoxShadow(color: C.green.withOpacity(.38), blurRadius: 26, offset: const Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: const DotsPainter(color: Colors.white12)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 17),
                    const SizedBox(width: 6),
                    Text(
                      l.t('available').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: w800, letterSpacing: 1.6),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: s.available),
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    money(v, store.sym),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: w800,
                      letterSpacing: -1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _mini(context, Icons.arrow_downward_rounded, l.t('inL'), money(s.inT, store.sym)),
                    Container(width: 1, height: 34, color: Colors.white24),
                    _mini(context, Icons.arrow_upward_rounded, l.t('outL'), money(s.outT, store.sym)),
                    Container(width: 1, height: 34, color: Colors.white24),
                    _mini(context, Icons.savings_rounded, l.t('savedL'), money(s.savedT, store.sym)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(BuildContext ctx, IconData i, String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(i, size: 13, color: Colors.white70),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: w700)),
            ]),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: w800, fontSize: 14.5, letterSpacing: -.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.store, required this.s});
  final Store store;
  final dynamic s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final pct = s.pctUsed as double;
    final thr = store.st.threshold;
    late final Level lv;
    late final String label;
    if (pct >= 100) {
      lv = Level.bad;
      label = l.t('statusOver');
    } else if (pct >= thr) {
      lv = Level.warn;
      label = l.t('statusWatch');
    } else {
      lv = Level.good;
      label = l.t('statusSafe');
    }
    final col = switch (lv) {
      Level.bad => C.red,
      Level.warn => C.amber,
      _ => C.green,
    };
    final projOver = s.overProj as double;

    return SoftCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetPage())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l.t('budget'), style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: col.withOpacity(.13), borderRadius: BorderRadius.circular(20)),
                child: Text(label, style: TextStyle(color: col, fontSize: 11, fontWeight: w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(s.outT, store.sym),
                style: const TextStyle(fontWeight: w800, fontSize: 21, letterSpacing: -.6),
              ),
              Text(
                ' / ${money(s.budget, store.sym)}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: w700, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '${pct.round()}%',
                style: TextStyle(fontWeight: w800, fontSize: 16, color: col, letterSpacing: -.4),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Bar(pct / 100, color: col),
            if (projOver > 0 && pct < 100) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 14, color: C.red),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      l.t('projWarnV').replaceAll('{v}', money(projOver, store.sym)),
                      style: const TextStyle(fontSize: 11.5, color: C.red, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

class _Alerts extends StatefulWidget {
  const _Alerts({required this.s, required this.prev, required this.store});
  final dynamic s;
  final dynamic prev;
  final Store store;

  @override
  State<_Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<_Alerts> {
  final dismissed = <int>{};

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final s = widget.s;
    final prev = widget.prev;
    final p = s.pctUsed as double;
    final thr = widget.store.st.threshold;
    final pers = widget.store.st.personality;
    final items = <Widget>[];

    if ((s.budget as double) > 0) {
      MsgType mt;
      if (p >= 100) {
        mt = MsgType.over;
      } else if (p >= thr) {
        mt = switch (thr) { 80 => MsgType.budget80, 90 => MsgType.budget90, _ => MsgType.budget70 };
      } else {
        mt = MsgType.budget70;
      }
      if (p >= thr || p >= 100) {
        items.add(AlertBar(
          l.msg(mt, pers, {
            'pct': '${p.round()}',
            'left': money((s.budget as double) - (s.outT as double), widget.store.sym),
          }),
          level: p >= 100 ? Level.bad : Level.warn,
          key: ValueKey('b$items.length'),
        ));
      }
    }

    final more = (s.savedT as double) - (prev.savedT as double);
    if (more > 0 && (prev.savedT as double) > 0) {
      items.add(AlertBar(
        l.msg(MsgType.savedMore, pers, {'more': money(more, widget.store.sym)}),
        level: Level.good,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          if (!dismissed.contains(i))
            KeyedSubtree(key: ValueKey('al$i'), child: items[i]),
      ].take(3).toList(),
    );
  }
}

class _ActiveGoal extends StatelessWidget {
  const _ActiveGoal({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final active = store.d.goals.where((g) => !g.done).toList()
      ..sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });

    if (active.isEmpty) {
      if (store.d.goals.isEmpty) {
        return SoftCard(
          onTap: () => openGoals(context),
          child: Row(
            children: [
              const IconBubble(Icons.flag_rounded, color: C.violet, soft: C.violetSoft),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.t('emptyGoalT'), style: const TextStyle(fontWeight: w800, fontSize: 15)),
                    Text(l.t('emptyGoalS'), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final g = active.first;
    final req = g.deadline != null ? reqMonthly(g.remaining, g.deadline!) : 0.0;
    return SoftCard(
      onTap: () => openGoals(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(g.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  g.name,
                  style: const TextStyle(fontWeight: w800, fontSize: 16, letterSpacing: -.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${g.pct.round()}%', style: const TextStyle(fontWeight: w800, fontSize: 15, color: C.violet)),
            ],
          ),
          const SizedBox(height: 12),
          Bar(g.pct / 100, color: C.violet),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${money(g.saved, store.sym)} / ${money(g.target, store.sym)}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: w700, fontSize: 12),
              ),
              const Spacer(),
              if (req > 0)
                Text(
                  l.t('reqMo').replaceAll('{v}', money(req, store.sym)),
                  style: const TextStyle(fontSize: 11.5, fontWeight: w700, color: C.violet),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
