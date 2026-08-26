import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../l10n/L.dart';
import 'add_tx_sheet.dart';
import 'analysis.dart';
import 'dashboard.dart';
import 'goals.dart';
import 'widgets/common.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  void _go(int i) => setState(() => _i = i);

  void _openAdd() {
    showSheet(context, builder: (_) => const AddTxSheet());
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _i,
        children: [
          Dashboard(onTab: (t) {
            if (t == 'goals') _go(1);
          }),
          AnalysisPage(),
          GoalsPage(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: _openAdd,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [C.green, C.greenDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: C.green.withOpacity(.45),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? .35 : .08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _navBtn(context, Icons.home_rounded, l.t('home'), 0)),
            Expanded(child: _navBtn(context, Icons.pie_chart_rounded, l.t('analysis'), 1)),
            const SizedBox(width: 64),
            Expanded(child: _navBtn(context, Icons.savings_rounded, l.t('goals'), 2)),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(BuildContext ctx, IconData icon, String label, int idx) {
    final sel = _i == idx;
    final c = sel ? C.green : Theme.of(ctx).textTheme.bodySmall!.color;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _go(idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: sel ? C.green.withOpacity(.13) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 24, color: c),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
              color: c,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

void openAddSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const AddTxSheet(),
    ),
  );
}
