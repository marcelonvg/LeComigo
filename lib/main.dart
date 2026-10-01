import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/sons.dart';
import 'services/vosk_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(Sons.carregar());
  runApp(
    Provider<VoskService>(
      create: (_) => VoskService(),
      child: const LeComigoApp(),
    ),
  );
}
