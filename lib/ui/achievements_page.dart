import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import 'widgets/common.dart';

const defs = <(String, IconData)>[
  ('first', Icons.emoji_people_rounded),
  ('streak7', Icons.local_fire_department_rounded),
  ('fivek', Icons.paid_rounded),
  ('under', Icons.check_circle_outline_rounded),
  ('crusher', Icons.flag_circle_rounded),
  ('month1', Icons.calendar_month_rounded),
  ('master', Icons.workspace_premium_rounded),
];

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final l = L.of(context);
    final unlocked = store.d.achv;
    final streak = store.streak;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('achT'))),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          SoftCard(
            pad: 20,
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [C.amber, C.orange]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: C.amber.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.t('streakDaysV').replaceAll('{n}', '$streak'),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -.4),
                      ),
                      const SizedBox(height: 7),
                      Bar(unlocked.length / defs.length, color: C.amber),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .92,
            ),
            itemCount: defs.length,
            itemBuilder: (ctx, i) {
              final id = defs[i].$1;
              final icon = defs[i].$2;
              final has = unlocked.contains(id);
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return SoftCard(
                pad: 14,
                radius: 22,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: has ? C.amber.withOpacity(.16) : (isDark ? C.bgDark : C.bgLight),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 27, color: has ? C.amber : (isDark ? C.subDark : C.subLight)),
                        ),
                        if (!has)
                          Positioned(
                            bottom: -1,
                            right: -1,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isDark ? C.cardDark : C.cardLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.lock_rounded, size: 13, color: isDark ? C.subDark : C.subLight),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.t('a_$id'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: has ? null : Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l.t('a_${id}_d'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10.8),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(l.t('keepGoing'), style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
