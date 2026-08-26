import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../l10n/L.dart';
import '../services/backup.dart' as bk;
import '../state/store.dart';
import 'budget_page.dart';
import 'widgets/common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final s = store.st;

    String langLabel(String v) => v == 'hi' ? 'हिंदी' : 'English';
    String themeLabel(String v) => v == 'light'
        ? l.t('light')
        : v == 'dark'
            ? l.t('dark')
            : l.t('system');
    String pLabel(String v) => switch (v) {
          'funny' => l.t('pFunny'),
          'sarcastic' => l.t('pSarcastic'),
          'serious' => l.t('pSerious'),
          _ => l.t('pNormal'),
        };

    return Scaffold(
      appBar: AppBar(title: Text(l.t('setT'))),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          SoftCard(
            pad: 16,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: C.green.withOpacity(.15),
                child: Text(
                  s.name.isEmpty
                      ? '🙂'
                      : s.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: s.name.isEmpty ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: C.green,
                  ),
                ),
              ),
              title: Text(s.name.isEmpty ? l.t('profile') : s.name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(l.t('nameL'), style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _editName(context),
            ),
          ),
          const SizedBox(height: 14),

          SectionHead(l.t('appearance')),
          SoftCard(
            pad: 4,
            child: Column(
              children: [
                _tile(context, Icons.translate_rounded, l.t('language'), langLabel(s.lang),
                    () async {
                  final v = await pickOption<String>(context,
                      title: l.t('language'),
                      current: s.lang,
                      options: [
                        ('en', 'English', null, null),
                        ('hi', 'हिंदी', null, null),
                      ]);
                  if (v != null) context.read<Store>().patch((x) => x.lang = v);
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.dark_mode_rounded, l.t('appearance'), themeLabel(s.theme),
                    () async {
                  final v = await pickOption<String>(context,
                      title: l.t('appearance'),
                      current: s.theme,
                      options: [
                        ('light', l.t('light'), Icons.light_mode_rounded, null),
                        ('dark', l.t('dark'), Icons.dark_mode_rounded, null),
                        ('system', l.t('system'), Icons.settings_suggest_rounded, null),
                      ]);
                  if (v != null) context.read<Store>().patch((x) => x.theme = v);
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.currency_rupee_rounded, l.t('currencyL'),
                    '${store.sym}  ${s.currency}', () async {
                  final v = await pickOption<String>(context,
                      title: l.t('currencyL'),
                      current: s.currency,
                      options: [
                        ('INR', l.t('curINR'), null, null),
                        ('USD', l.t('curUSD'), null, null),
                        ('EUR', l.t('curEUR'), null, null),
                      ]);
                  if (v != null) context.read<Store>().patch((x) => x.currency = v);
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.speed_rounded, l.t('budTitle'),
                    s.budget > 0 ? money(s.budget, store.sym) : '—', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetPage()));
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SectionHead(l.t('notifsL')),
          SoftCard(
            pad: 4,
            child: Column(
              children: [
                SwitchTile(
                  icon: Icons.notifications_active_rounded,
                  title: l.t('dailyTime'),
                  value: s.nDaily,
                  onChanged: (v) => context.read<Store>().patch((x) => x.nDaily = v),
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.schedule_rounded, l.t('dailyTime'), s.dailyTime, () async {
                  final p = s.dailyTime.split(':');
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                        hour: int.tryParse(p[0]) ?? 20, minute: int.tryParse(p.length > 1 ? p[1] : '') ?? 0),
                  );
                  if (picked != null) {
                    context.read<Store>().patch((x) => x.dailyTime =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                  }
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                SwitchTile(
                  icon: Icons.warning_rounded,
                  title: l.t('thresholdL'),
                  value: s.nBudget,
                  onChanged: (v) => context.read<Store>().patch((x) => x.nBudget = v),
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.percent_rounded, l.t('thresholdL'), '${s.threshold}%', () async {
                  final v = await pickOption<int>(context,
                      title: l.t('thresholdL'),
                      current: s.threshold,
                      options: [(70, '70%', null, null), (80, '80%', null, null), (90, '90%', null, null)]);
                  if (v != null) context.read<Store>().patch((x) => x.threshold = v);
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                SwitchTile(
                  icon: Icons.flag_rounded,
                  title: l.t('goalsT'),
                  value: s.nGoal,
                  onChanged: (v) => context.read<Store>().patch((x) => x.nGoal = v),
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                SwitchTile(
                  icon: Icons.description_outlined,
                  title: l.t('repTitle'),
                  value: s.nSummary,
                  onChanged: (v) => context.read<Store>().patch((x) => x.nSummary = v),
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                SwitchTile(
                  icon: Icons.repeat_rounded,
                  title: l.t('repeatMonthly'),
                  value: s.nRecurring,
                  onChanged: (v) => context.read<Store>().patch((x) => x.nRecurring = v),
                ),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                SwitchTile(
                  icon: Icons.emoji_events_rounded,
                  title: l.t('achievements'),
                  value: s.nAchv,
                  onChanged: (v) => context.read<Store>().patch((x) => x.nAchv = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SectionHead(l.t('personality')),
          SoftCard(
            pad: 16,
            onTap: () async {
              final v = await pickOption<String>(context,
                  title: l.t('personality'),
                  current: s.personality,
                  options: [
                    ('normal', l.t('pNormal'), null, null),
                    ('funny', l.t('pFunny'), null, null),
                    ('sarcastic', l.t('pSarcastic'), null, null),
                    ('serious', l.t('pSerious'), null, null),
                  ]);
              if (v != null) context.read<Store>().patch((x) => x.personality = v);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBubble(Icons.theater_comedy_rounded, color: C.violet, soft: C.violetSoft),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(pLabel(s.personality),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l.t('sampleL')}:',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        l.msg(MsgType.budget70, s.personality, {'pct': '70'}),
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SectionHead(l.t('dataSec')),
          SoftCard(
            pad: 8,
            child: Column(
              children: [
                _tile(context, Icons.cloud_upload_rounded, l.t('backup'), '', () async {
                  final ok = await bk.Backup.exportJson(store.d);
                  _snack(context, l.t(ok ? 'backupDone' : 'failOp'));
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.restore_rounded, l.t('restore'), '', () async {
                  final ok = await _confirm(context, l.t('replaceQ'));
                  if (ok != true) return;
                  final data = await bk.Backup.importJson();
                  if (!context.mounted) return;
                  if (data != null) {
                    context.read<Store>().replaceAll(data);
                    _snack(context, l.t('restored'));
                  } else {
                    _snack(context, l.t('failOp'));
                  }
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.table_view_rounded, l.t('exportCsv'), '', () async {
                  final ok = await bk.Backup.exportCsv(store.d.txs);
                  _snack(context, l.t(ok ? 'exportDone' : 'failOp'));
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.upload_file_rounded, l.t('importCsv'), '', () async {
                  final txs = await bk.Backup.importCsv();
                  if (!context.mounted) return;
                  if (txs == null) {
                    _snack(context, l.t('failOp'));
                  } else {
                    context.read<Store>().importCsvMerge(txs);
                    _snack(context, l.t('importDone'));
                  }
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SoftCard(
            pad: 6,
            child: Column(
              children: [
                _tile(context, Icons.lock_outline_rounded, l.t('privacy'), '', () {
                  showDialog<void>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: Text(l.t('privacy')),
                      content: Text(l.t('privacyBody')),
                      actions: [TextButton(onPressed: () => Navigator.pop(d), child: Text(l.t('ok')))],
                    ),
                  );
                }),
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerTheme.color),
                _tile(context, Icons.info_outline_rounded, l.t('about'), '', () {
                  showDialog<void>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [C.green, C.greenDark]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.savings_rounded, color: Colors.white, size: 21),
                        ),
                        const SizedBox(width: 10),
                        const Text('SaveWise'),
                      ]),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.t('aboutBody')),
                          const SizedBox(height: 10),
                          Text(l.t('verL'), style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 12),
                          Text(
                            'Created by priyanshu (@priyanshuwithadhd)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(d), child: Text(l.t('ok')))],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _snack(BuildContext ctx, String m) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<bool?> _confirm(BuildContext ctx, String q) {
    final l = L.of(ctx);
    return showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: Text(q),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l.t('confirm'))),
        ],
      ),
    );
  }

  void _editName(BuildContext ctx) {
    final store = ctx.read<Store>();
    final c = TextEditingController(text: store.st.name);
    final l = L.of(ctx);
    showDialog<void>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: Text(l.t('nameL')),
        content: TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(l.t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () {
              ctx.read<Store>().setName(c.text.trim());
              Navigator.pop(d);
              _snack(ctx, l.t('nameSaved'));
            },
            child: Text(l.t('save')),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext ctx, IconData i, String title, String value, VoidCallback onTap) {
    final sub = Theme.of(ctx).textTheme.bodySmall!.color;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(i, color: C.green, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      subtitle: value.isEmpty ? null : Text(value, style: TextStyle(fontSize: 12.5, color: sub)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

class SwitchTile extends StatelessWidget {
  const SwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      secondary: Icon(icon, color: C.green, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      value: value,
      onChanged: onChanged,
    );
  }
}
