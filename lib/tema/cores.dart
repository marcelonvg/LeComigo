import 'package:flutter/painting.dart';

/// Paleta do app. Nenhuma tela deve declarar cores soltas: use estas.
abstract final class Cores {
  // Marca
  static const grafite = Color(0xFF23262B);
  static const amarelo = Color(0xFFF5B800);
  static const amareloSombra = Color(0xFFCC9900);
  static const amareloClaro = Color(0xFFFFF4D1);
  static const amareloEscuro = Color(0xFF8A6500);
  static const teal = Color(0xFF0E9F9A);
  static const tealSombra = Color(0xFF0A7772);
  static const tealClaro = Color(0xFFDDF5F2);
  static const tealVivo = Color(0xFF22BCCB);
  static const tealBrilho = Color(0xFF1FC2B3);

  // Neutros
  static const fundo = Color(0xFFFFFFFF);
  static const fundoSplash = Color(0xFFFEFEFE); // mesmo branco da ilustração
  static const fundoSuave = Color(0xFFF6F7F8);
  static const texto = Color(0xFF3C3F45);
  static const textoSuave = Color(0xFF8A8F98);
  static const textoDesabilitado = Color(0xFFAFAFAF);
  static const textoAzulado = Color(0xFF5B6B8A);
  static const borda = Color(0xFFE5E5E5);
  static const bordaSombra = Color(0xFFD0D0D0);
  static const trilho = Color(0xFFE3EAF2); // fundo de barras de progresso

  // Estados
  static const erro = Color(0xFFC62828);
}
