import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models.dart';

class Backup {
  static Future<bool> exportJson(AppData d) async {
    try {
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}${Platform.pathSeparator}savewise_backup.json');
      await f.writeAsString(
        const JsonEncoder.withIndent('  ').convert(d.toJson()),
      );
      await Share.shareXFiles([XFile(f.path)], text: 'SaveWise backup');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<AppData?> importJson() async {
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.any);
      final path = r?.files.single.path;
      if (path == null) return null;
      return AppData.fromJson(
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> exportCsv(List<Tx> txs) async {
    try {
      final sb = StringBuffer('date,type,label,amount,note,recurring\n');
      for (final t in txs) {
        final note = t.note.replaceAll('"', "'");
        sb.writeln([
          t.date.toIso8601String(),
          t.kind.name,
          t.key,
          t.amount.toStringAsFixed(2),
          '"$note"',
          t.recurring,
        ].join(','));
      }
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}${Platform.pathSeparator}savewise_export.csv');
      await f.writeAsString(sb.toString());
      await Share.shareXFiles([XFile(f.path)], text: 'SaveWise export');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Tx>?> importCsv() async {
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.any);
      final path = r?.files.single.path;
      if (path == null) return null;
      final lines = File(path).readAsLinesSync();
      if (lines.length < 2) return [];
      final out = <Tx>[];
      for (var i = 1; i < lines.length; i++) {
        final parts = _splitCsv(lines[i]);
        if (parts.length < 6) continue;
        final date = DateTime.tryParse(parts[0]);
        final amount = double.tryParse(parts[3]);
        if (date == null || amount == null) continue;
        out.add(Tx(
          id: 'imp${date.microsecondsSinceEpoch}$i',
          kind: kindOf(parts[1]),
          amount: amount,
          key: parts[2],
          note: parts[4].replaceAll("'", '"'),
          date: date,
          recurring: parts[5].toLowerCase() == 'true',
        ));
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  static List<String> _splitCsv(String line) {
    final out = <String>[];
    var cur = '';
    var inQ = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        inQ = !inQ;
      } else if (c == ',' && !inQ) {
        out.add(cur);
        cur = '';
      } else {
        cur += c;
      }
    }
    out.add(cur);
    return out;
  }
}
