import 'package:flutter/material.dart';

import 'cores.dart';

export 'cores.dart';
export 'estilos.dart';

/// Tema Material do app. Importar este arquivo já traz Cores e Estilos.
ThemeData temaApp() => ThemeData(
  fontFamily: 'Fredoka',
  scaffoldBackgroundColor: Cores.fundo,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Cores.teal,
    primary: Cores.teal,
    surface: Cores.fundo,
  ),
);
