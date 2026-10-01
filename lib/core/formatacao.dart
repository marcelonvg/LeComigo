// Formatação de valores para exibição. Dart puro.

/// 75 s → "1:15".
String formatarMinSeg(Duration d) {
  final segundos = d.isNegative ? 0 : d.inSeconds;
  return '${segundos ~/ 60}:${(segundos % 60).toString().padLeft(2, '0')}';
}
