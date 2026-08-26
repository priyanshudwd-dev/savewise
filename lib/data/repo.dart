import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'models.dart';

class Repo {
  File? _f;

  Future<File> _file() async {
    _f ??= File(
      '${(await getApplicationDocumentsDirectory()).path}${Platform.pathSeparator}savewise_data.json',
    );
    return _f!;
  }

  Future<AppData> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return AppData();
      return AppData.fromJson(jsonDecode(await f.readAsString()) as Map<String, dynamic>);
    } catch (_) {
      return AppData();
    }
  }

  Future<void> save(AppData d) async {
    try {
      final f = await _file();
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsString(jsonEncode(d.toJson()));
      if (await f.exists()) await f.delete();
      await tmp.rename(f.path);
    } catch (_) {}
  }
}
