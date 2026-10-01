import 'package:flutter/material.dart';
import 'package:le_comigo/l10n/app_localizations.dart';

/// MaterialApp com as traduções do app, em [locale] (português por padrão).
MaterialApp appTeste(
  Widget home, {
  Locale locale = const Locale('pt'),
  TransitionBuilder? builder,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: builder,
  home: home,
);
