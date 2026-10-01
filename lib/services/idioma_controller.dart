import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/idioma.dart';

/// Idioma escolhido, salvo no aparelho. O MaterialApp escuta este
/// controller: trocar o idioma traduz a tela na hora.
class IdiomaController extends ChangeNotifier {
  /// Sem nada salvo (1ª abertura), usa o idioma do aparelho
  /// ([codigoAparelho]) se o app o tiver; senão, português.
  IdiomaController(this._prefs, {String? codigoAparelho})
    : _atual =
          Idioma.doCodigo(_prefs.getString(chave)) ??
          Idioma.doCodigo(codigoAparelho) ??
          Idioma.pt;

  static const chave = 'idioma';

  static Future<IdiomaController> carregar({String? codigoAparelho}) async =>
      IdiomaController(
        await SharedPreferences.getInstance(),
        codigoAparelho: codigoAparelho,
      );

  final SharedPreferences _prefs;
  Idioma _atual;

  Idioma get atual => _atual;

  Future<void> escolher(Idioma idioma) async {
    if (idioma == _atual) return;
    _atual = idioma;
    notifyListeners();
    await _prefs.setString(chave, idioma.codigo);
  }
}
