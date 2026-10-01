import 'package:flutter/material.dart';

import 'screens/biblioteca/biblioteca_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'tema/tema_app.dart';

class LeComigoApp extends StatelessWidget {
  const LeComigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lê Comigo',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      home: SplashScreen(proximaTela: (_) => const BibliotecaScreen()),
    );
  }
}
