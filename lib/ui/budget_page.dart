import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import 'widgets/common.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late TextEditingController c;

  @override
  void initState() {
    super.initState();
    final b = context.read<Store>().st.budget;
    c = TextEditingController(text: b == 0 ? '' : b.toStringAsFixed(0));
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final s = store.curStats;
    final l = L.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('budTitle'))),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          if (s.budget > 0) ...[
            SoftCard(
              pad: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.t('used'), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${s.pctUsed.round()}%',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: s.pctUsed >= 100 ? C.red : (s.pctUsed >= s.budget * .7 ? C.amber : C.green),
                        ),
                      ),
                      Text(' ${l.t('ofBudget')}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Bar(s.pctUsed / 100, color: s.pctUsed >= 100 ? C.red : (s.pctUsed >= s.budget * .7 ? C.amber : C.green), height: 12),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _kv(context, l.t('spent'), money(s.outT, store.sym), C.red)),
                      Container(width: 1, height: 34, color: isDark ? C.lineDark : C.lineLight),
                      Expanded(child: _kv(context, l.t('remain'), money((s.budget - s.outT).clamp(0, 1e12), store.sym), C.green)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                children: [
                  _row(context, Icons.speed_rounded, l.t('paceDay'),
                      l.t('paceLine').replaceAll('{v}', money(s.pace, store.sym))),
                  Divider(height: 22, color: isDark ? C.lineDark : C.lineLight),
                  _row(context, Icons.query_stats_rounded, l.t('projSpend'), money(s.projected, store.sym)),
                  Divider(height: 22, color: isDark ? C.lineDark : C.lineLight),
                  _row(context, Icons.event_available_rounded,
                      l.t('dayXofY').replaceAll('{x}', '${s.daysElapsed}').replaceAll('{y}', '${s.daysInMonth}'),
                      l.t('leftDays').replaceAll('{d}', '${s.daysInMonth - s.daysElapsed}')),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AlertBar(
              s.overProj > 0
                  ? l.t('projWarnV').replaceAll('{v}', money(s.overProj, store.sym))
                  : l.t('projOkV'),
              level: s.overProj > 0 ? Level.warn : Level.good,
            ),
          ] else ...[
            EmptyState(
              icon: Icons.speed_rounded,
              title: l.t('noBudgetT'),
              sub: l.t('noBudgetS'),
            ),
            const SizedBox(height: 8),
          ],

          SoftCard(
            pad: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.st.budget > 0 ? l.t('editBud') : l.t('setNow'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: c,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: l.t('budHint'),
                    prefixText: ' ${store.sym} ',
                    prefixStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.green),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(onPressed: _save, child: Text(l.t('saveBud'))),
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
        Text(v, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c, letterSpacing: -.4)),
        const SizedBox(height: 2),
        Text(k, style: Theme.of(ctx).textTheme.bodySmall!.copyWith(fontSize: 11.5)),
      ],
    );
  }

  Widget _row(BuildContext ctx, IconData i, String k, String v) {
    return Row(
      children: [
        Icon(i, size: 18, color: C.blue),
        const SizedBox(width: 10),
        Expanded(child: Text(k, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
        Text(v, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
      ],
    );
  }

  void _save() {
    final v = double.tryParse(c.text.trim()) ?? 0;
    context.read<Store>().patch((s) => s.budget = v);
    Navigator.pop(context);
  }
}
