import 'package:flutter/material.dart';

import '../../core/cats.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../l10n/L.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.pad = 18,
    this.radius = 22,
    this.color,
    this.onTap,
  });

  final Widget child;
  final double pad;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: color ?? (isDark ? C.cardDark : C.cardLight),
        borderRadius: BorderRadius.circular(radius),
        boxShadow:
            isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(padding: EdgeInsets.all(pad), child: child),
        ),
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  const SectionHead(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final sub = Theme.of(context).textTheme.bodySmall!.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: TextStyle(
                  color: C.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          if (action != null) Icon(Icons.chevron_right_rounded, size: 18, color: sub),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final soft = color.withOpacity(isDark ? .16 : .12);
    return SoftCard(
      pad: 14,
      radius: 20,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
              letterSpacing: -.3,
              color: isDark ? C.textDark : C.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

class Bar extends StatelessWidget {
  const Bar(this.p, {super.key, this.color = C.green, this.height = 9, this.track});

  final double p;
  final Color color;
  final double height;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = track ?? (isDark ? C.lineDark : C.bgLight);
    final v = p.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(decoration: BoxDecoration(color: bg)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: v),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: val,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withOpacity(.85), color]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum Level { info, good, warn, bad }

class AlertBar extends StatelessWidget {
  const AlertBar(this.text, {super.key, required this.level, this.onClose});

  final String text;
  final Level level;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    late final Color c;
    late final IconData i;
    switch (level) {
      case Level.good:
        c = C.green;
        i = Icons.emoji_events_rounded;
      case Level.warn:
        c = C.amber;
        i = Icons.warning_amber_rounded;
      case Level.bad:
        c = C.red;
        i = Icons.error_outline_rounded;
      case Level.info:
        c = C.blue;
        i = Icons.info_outline_rounded;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: c.withOpacity(isDark ? .13 : .1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Icon(i, color: c, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: c.computeLuminance() > .5 ? c : null,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
              ).apply(color: isDark ? c.lighten() : c.darken()),
            ),
          ),
          if (onClose != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, size: 17, color: c),
            ),
        ],
      ),
    );
  }
}

extension _CX on Color {
  Color lighten() => Color.lerp(this, Colors.white, .35)!;
  Color darken() => Color.lerp(this, Colors.black, .25)!;
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
    this.cta,
    this.onCta,
  });

  final IconData icon;
  final String title;
  final String sub;
  final String? cta;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [C.green.withOpacity(.18), C.violet.withOpacity(.14)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: C.green),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
                color: isDark ? C.textDark : C.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (cta != null && onCta != null) ...[
              const SizedBox(height: 22),
              FilledButton(onPressed: onCta, child: Text(cta!)),
            ],
          ],
        ),
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble(this.data, {super.key, required this.color, required this.soft, this.size = 42});

  final IconData data;
  final Color color;
  final Color soft;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(size * .32)),
      child: Icon(data, color: color, size: size * .5),
    );
  }
}

class TxTile extends StatelessWidget {
  const TxTile({super.key, required this.tx, required this.sym, this.onEdit, this.onDelete});

  final Tx tx;
  final String sym;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final isIn = tx.kind == Kind.credit;
    final color = isIn ? C.green : C.red;
    final label = isIn ? l.src(tx.key) : l.cat(tx.key);
    final icon = isIn ? srcIcon(tx.key) : catIcon(tx.key);
    final bubble = isIn ? srcSoft(tx.key) : catSoft(tx.key);
    final tint = isIn ? srcColor(tx.key) : catColor(tx.key);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        pad: 12,
        radius: 18,
        child: Row(
          children: [
            IconBubble(icon, color: tint, soft: bubble),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tx.note.isNotEmpty)
                    Text(
                      tx.note,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (tx.recurring)
                    Row(
                      children: [
                        Icon(Icons.repeat_rounded, size: 12, color: Theme.of(context).textTheme.bodySmall!.color),
                        const SizedBox(width: 3),
                        Text('monthly', style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              signed(isIn ? tx.amount : -tx.amount, sym),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: color,
                letterSpacing: -.2,
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                splashRadius: 18,
                iconSize: 18,
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'e', child: Row(children: [const Icon(Icons.edit_rounded, size: 17), const SizedBox(width: 8), Text(l.t('edit'))])),
                  PopupMenuItem(value: 'd', child: Row(children: [const Icon(Icons.delete_outline_rounded, size: 17), const SizedBox(width: 8), Text(l.t('delete'))])),
                ],
                onSelected: (v) {
                  if (v == 'e') onEdit?.call();
                  if (v == 'd') onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  const DotsPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const gap = 16.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotsPainter oldDelegate) => oldDelegate.color != color;
}

void showSheet(BuildContext context, {required Widget Function(BuildContext) builder, bool full = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * (full ? .92 : .88)),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(ctx).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), child: builder(ctx))),
        ),
      ),
    ),
  );
}

typedef Opt<T> = (T, String, IconData?, String?);

Future<T?> pickOption<T>(
  BuildContext context, {
  required String title,
  required List<Opt<T>> options,
  required T current,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(title, style: Theme.of(ctx).textTheme.titleLarge),
          ),
          ...options.map((o) {
            final sel = o.$1 == current;
            return ListTile(
              leading: o.$3 != null
                  ? Icon(o.$3, color: sel ? C.green : null)
                  : (o.$4 != null
                      ? Text(o.$4!, style: const TextStyle(fontSize: 20))
                      : null),
              title: Text(
                o.$2,
                style: TextStyle(fontWeight: sel ? FontWeight.w800 : FontWeight.w500),
              ),
              trailing: sel ? const Icon(Icons.check_circle_rounded, color: C.green) : null,
              onTap: () => Navigator.pop(ctx, o.$1),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    ),
  );
}
