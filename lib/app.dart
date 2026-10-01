import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/biblioteca/biblioteca_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/idioma_controller.dart';
import 'tema/tema_app.dart';

class LeComigoApp extends StatelessWidget {
  const LeComigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final idioma = context.watch<IdiomaController>().atual;
    return MaterialApp(
      title: 'Lê Comigo',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      locale: Locale(idioma.codigo),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SplashScreen(proximaTela: (_) => const BibliotecaScreen()),
    );
  }
}
