import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/idioma_controller.dart';
import 'services/sons.dart';
import 'services/vosk_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(Sons.carregar());
  // Lido antes do runApp: a splash já aparece no idioma certo.
  final idioma = await IdiomaController.carregar(
    codigoAparelho:
        WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<VoskService>(create: (_) => VoskService()),
        ChangeNotifierProvider<IdiomaController>.value(value: idioma),
      ],
      child: const LeComigoApp(),
    ),
  );
}
