import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/L.dart';
import 'services/notif.dart';
import 'state/store.dart';
import 'ui/onboarding.dart';
import 'ui/shell.dart';
import 'data/repo.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notif = Notif();
  await notif.init();
  final repo = Repo();
  final store = Store(repo, notif);
  await store.bootstrap();
  runApp(SaveWiseApp(store));
}

class SaveWiseApp extends StatelessWidget {
  const SaveWiseApp(this.store, {super.key});
  final Store store;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: store,
      child: Consumer<Store>(
        builder: (context, s, _) {
          final dark = s.themeMode;
          return MaterialApp(
            title: 'SaveWise',
            debugShowCheckedModeBanner: false,
            locale: Locale(s.lang),
            supportedLocales: const [Locale('en'), Locale('hi')],
            localizationsDelegates: const [
              LDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: dark,
            home: s.onboarded ? const Shell() : const Onboarding(),
          );
        },
      ),
    );
  }
}
