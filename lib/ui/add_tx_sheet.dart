import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/cats.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../l10n/L.dart';
import '../state/store.dart';

class AddTxSheet extends StatefulWidget {
  const AddTxSheet({super.key, this.existing});

  final Tx? existing;

  @override
  State<AddTxSheet> createState() => _AddTxSheetState();
}

class _AddTxSheetState extends State<AddTxSheet> {
  late Kind kind;
  late TextEditingController amountC;
  late TextEditingController noteC;
  late String key;
  late DateTime date;
  late bool recurring;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    kind = e?.kind ?? Kind.debit;
    amountC = TextEditingController(text: e == null ? '' : e.amount == 0 ? '' : e.amount.toStringAsFixed(0));
    noteC = TextEditingController(text: e?.note ?? '');
    key = e?.key ?? (e?.kind == Kind.credit ? 'parents' : 'food');
    date = e?.date ?? DateTime.now();
    recurring = e?.recurring ?? false;
  }

  @override
  void dispose() {
    amountC.dispose();
    noteC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.existing == null ? l.t('addTx') : l.t('edit'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (widget.existing != null)
              IconButton(
                onPressed: () async {
                  final ok = await _confirm(context, l.t('delTxQ'));
                  if (ok == true && context.mounted) {
                    context.read<Store>().deleteTx(widget.existing!.id);
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded, color: C.red),
              ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _seg(context, l.t('moneyIn'), Icons.south_west_rounded, C.green, kind == Kind.credit,
                  () => setState(() { kind = Kind.credit; key = 'parents'; })),
              _seg(context, l.t('moneyOut'), Icons.north_east_rounded, C.red, kind == Kind.debit,
                  () => setState(() { kind = Kind.debit; key = 'food'; })),
            ],
          ),
        ),
        const SizedBox(height: 18),

        TextField(
          controller: amountC,
          autofocus: widget.existing == null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.8),
          decoration: InputDecoration(
            prefixText: ' ${context.read<Store>().sym} ',
            prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.green),
            hintText: '0',
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: noteC,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l.t('noteOpt')),
        ),
        const SizedBox(height: 16),

        Text(
          kind == Kind.credit ? l.t('source') : l.t('category'),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (kind == Kind.credit ? srcKeys : catKeys).map((k) {
            final sel = k == key;
            final icon = kind == Kind.credit ? srcIcon(k) : catIcon(k);
            final col = kind == Kind.credit ? srcColor(k) : catColor(k);
            final label = kind == Kind.credit ? l.src(k) : l.cat(k);
            return GestureDetector(
              onTap: () => setState(() => key = k),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? col.withOpacity(.16) : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? col : Colors.transparent, width: 1.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15, color: sel ? col : Theme.of(context).textTheme.bodySmall!.color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: sel ? w800 : FontWeight.w600,
                        color: sel ? col : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        if (kind == Kind.debit)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: recurring,
            onChanged: (v) => setState(() => recurring = v),
            title: Text(l.t('repeatMonthly'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),

        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (d != null) setState(() => date = d);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 19, color: Theme.of(context).textTheme.bodySmall!.color),
                const SizedBox(width: 8),
                Text(
                  date.sameDay(DateTime.now())
                      ? l.t('today')
                      : shortDate(date),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Theme.of(context).textTheme.bodySmall!.color),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        FilledButton(
          onPressed: () => _save(context),
          child: Text(l.t('save')),
        ),
      ],
    );
  }

  Widget _seg(BuildContext ctx, String label, IconData icon, Color c, bool sel, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: sel ? c : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: sel ? Colors.white : Theme.of(ctx).textTheme.bodySmall!.color),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: sel ? Colors.white : Theme.of(ctx).textTheme.bodySmall!.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BuildContext ctx) {
    final store = ctx.read<Store>();
    final amt = double.tryParse(amountC.text.trim()) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(L.of(ctx).t('invalidAmount'))));
      return;
    }
    final tx = Tx(
      id: widget.existing?.id ?? 't${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      amount: amt,
      key: key,
      note: noteC.text.trim(),
      date: date,
      recurring: kind == Kind.debit && recurring,
    );
    if (widget.existing == null) {
      store.addTx(tx);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(L.of(ctx).t('txSaved'))));
    } else {
      store.updateTx(tx);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(L.of(ctx).t('txUpdated'))));
    }
    Navigator.pop(ctx);
  }

  Future<bool?> _confirm(BuildContext ctx, String q) {
    final l = L.of(ctx);
    return showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: Text(q),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.red, minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(d, true),
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
  }

  static const w800 = FontWeight.w800;
}
