import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../l10n/L.dart';
import '../state/store.dart';
import '../services/notif.dart';
import 'widgets/common.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final pc = PageController();
  int page = 0;
  double budget = 0;
  String goalName = '';
  String goalTarget = '';
  DateTime? goalDeadline;
  final goalC = TextEditingController();
  final targetC = TextEditingController();

  @override
  void dispose() {
    pc.dispose();
    goalC.dispose();
    targetC.dispose();
    super.dispose();
  }

  void next() {
    if (page < 5) {
      pc.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _finish() {
    final store = context.read<Store>();
    store.patch((s) {
      s.budget = budget;
    });
    if (goalName.trim().isNotEmpty) {
      final t = double.tryParse(goalTarget.trim()) ?? 0;
      if (t > 0) {
        store.addGoal(Goal(
          id: 'g${DateTime.now().microsecondsSinceEpoch}',
          name: goalName.trim(),
          icon: '🎯',
          target: t,
          deadline: goalDeadline,
        ));
      }
    }
    Notif().permission();
    store.finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pc,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => page = i),
                children: [_welcome(), _lang(), _theme(), _budget(), _goal(), _notif()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          if (page == 2) context.read<Store>().patch((s) => s.budget = budget);
                          next();
                        },
                        child: Text(L.of(context).t('skip')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          if (page == 3) context.read<Store>().patch((s) => s.budget = budget);
                          if (page == 4 && goalName.trim().isNotEmpty) {
                            final t = double.tryParse(goalTarget.trim()) ?? 0;
                            if (t > 0) {
                              context.read<Store>().addGoal(Goal(
                                    id: 'g${DateTime.now().microsecondsSinceEpoch}',
                                    name: goalName.trim(),
                                    icon: '🎯',
                                    target: t,
                                    deadline: goalDeadline,
                                  ));
                            }
                          }
                          if (page == 5) {
                            _finish();
                          } else {
                            next();
                          }
                        },
                        child: Text(page == 5
                            ? L.of(context).t('letsGo')
                            : page == 0
                                ? L.of(context).t('start')
                                : L.of(context).t('next')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    final l = L.of(context);
    l.t('');
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          final sel = i == page;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: sel ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: sel ? C.green : C.green.withOpacity(.25),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _frame({required IconData icon, required String title, required String sub, Widget? control}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? C.textDark : C.textLight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [C.green.withOpacity(.22), C.violet.withOpacity(.18), C.blue.withOpacity(.15)],
              ),
              borderRadius: BorderRadius.circular(38),
            ),
            child: Icon(icon, size: 48, color: C.green),
          ),
          const SizedBox(height: 30),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.7, color: fg)),
          const SizedBox(height: 10),
          Text(sub, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14.5, height: 1.5)),
          if (control != null) ...[const SizedBox(height: 26), control],
          _dots(),
        ],
      ),
    );
  }

  Widget _welcome() {
    final l = L.of(context);
    return Stack(
      children: [
        Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: DotsPainter(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.04))))),
        Center(
          child: _frame(
            icon: Icons.savings_rounded,
            title: l.t('ob1T'),
            sub: l.t('ob1S'),
          ),
        ),
      ],
    );
  }

  Widget _lang() {
    final l = L.of(context);
    final cur = context.watch<Store>().st.lang;
    Widget opt(String v, String label) {
      final sel = cur == v;
      return GestureDetector(
        onTap: () => context.read<Store>().patch((s) => s.lang = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: sel ? C.green.withOpacity(.1) : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sel ? C.green : (Theme.of(context).brightness == Brightness.dark ? C.lineDark : C.lineLight), width: sel ? 1.8 : 1.2),
          ),
          child: Row(
            children: [
              Icon(Icons.language_rounded, size: 19, color: sel ? C.green : null),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: sel ? C.green : null))),
              if (sel) const Icon(Icons.check_circle_rounded, color: C.green, size: 20),
            ],
          ),
        ),
      );
    }

    return Center(
      child: _frame(
        icon: Icons.translate_rounded,
        title: l.t('obLangT'),
        sub: '',
        control: Column(children: [opt('en', 'English'), opt('hi', 'हिंदी')]),
      ),
    );
  }

  Widget _theme() {
    final l = L.of(context);
    final cur = context.watch<Store>().st.theme;
    Widget opt(String v, String label, IconData i) {
      final sel = cur == v;
      return GestureDetector(
        onTap: () => context.read<Store>().patch((s) => s.theme = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
          decoration: BoxDecoration(
            color: sel ? C.green.withOpacity(.1) : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sel ? C.green : (Theme.of(context).brightness == Brightness.dark ? C.lineDark : C.lineLight), width: sel ? 1.8 : 1.2),
          ),
          child: Row(
            children: [
              Icon(i, size: 19, color: sel ? C.green : null),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: sel ? C.green : null))),
              if (sel) const Icon(Icons.check_circle_rounded, color: C.green, size: 20),
            ],
          ),
        ),
      );
    }

    return Center(
      child: _frame(
        icon: Icons.contrast_rounded,
        title: l.t('obThemeT'),
        sub: l.t('obThemeS'),
        control: Column(children: [
          opt('light', l.t('light'), Icons.light_mode_rounded),
          opt('dark', l.t('dark'), Icons.dark_mode_rounded),
          opt('system', l.t('system'), Icons.settings_suggest_rounded),
        ]),
      ),
    );
  }

  Widget _budget() {
    final l = L.of(context);
    final sym = context.watch<Store>().sym;
    return Center(
      child: _frame(
        icon: Icons.speed_rounded,
        title: l.t('obBudT'),
        sub: l.t('obBudS'),
        control: SizedBox(
          width: 240,
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => budget = double.tryParse(v) ?? 0,
            decoration: InputDecoration(hintText: l.t('budHint'), prefixText: ' $sym ', prefixStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: C.green)),
          ),
        ),
      ),
    );
  }

  Widget _goal() {
    final l = L.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.violet.withOpacity(.22), C.green.withOpacity(.18)]),
                borderRadius: BorderRadius.circular(34),
              ),
              child: const Icon(Icons.flag_rounded, size: 44, color: C.violet),
            ),
            const SizedBox(height: 26),
            Text(l.t('obGoalT'), textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -.6, color: Theme.of(context).brightness == Brightness.dark ? C.textDark : C.textLight)),
            const SizedBox(height: 8),
            Text(l.t('obGoalS'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14, height: 1.5)),
            const SizedBox(height: 22),
            SizedBox(
              width: 250,
              child: TextField(
                controller: goalC,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => goalName = v,
                decoration: InputDecoration(hintText: l.t('goalName')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 250,
              child: TextField(
                controller: targetC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => goalTarget = v,
                decoration: InputDecoration(
                  hintText: l.t('target'),
                  prefixText: ' ${context.watch<Store>().sym} ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: C.violet),
                ),
              ),
            ),
            _dots(),
          ],
        ),
      ),
    );
  }

  Widget _notif() {
    final l = L.of(context);
    return Center(
      child: _frame(
        icon: Icons.notifications_active_rounded,
        title: l.t('obNotiT'),
        sub: l.t('obNotiS'),
        control: SizedBox(
          width: 230,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Notif().permission();
              next();
            },
            icon: const Icon(Icons.notifications_none_rounded),
            label: Text(l.t('allowNotifs')),
          ),
        ),
      ),
    );
  }
}
