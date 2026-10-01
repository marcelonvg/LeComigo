import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Efeitos sonoros do app (Kenney, CC0: ver assets/sons/LICENCA.txt).
enum Som {
  toque('toque.ogg'),
  escolha('escolha.ogg'),
  contagem('contagem.ogg'),
  sucesso('sucesso.ogg'),
  naoOuvi('nao_ouvi.ogg');

  const Som(this.arquivo);
  final String arquivo;
}

/// Toca os efeitos sonoros. Os widgets chamam [Sons.tocar] junto do
/// HapticFeedback, sem precisar de Provider.
///
/// Enquanto [carregar] não for chamado (nos testes, por exemplo), [tocar]
/// não faz nada. Falhas de áudio nunca derrubam a tela: som é enfeite.
abstract final class Sons {
  static final _players = <Som, AudioPlayer>{};

  /// Sem foco de áudio: não pausa a música de outro app nem disputa com
  /// o microfone do reconhecimento de voz.
  static final _contexto = AudioContext(
    android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
  );

  /// Pré-carrega todos os sons (modo de baixa latência do Android).
  static Future<void> carregar() async {
    for (final som in Som.values) {
      try {
        final player = AudioPlayer(playerId: 'som_${som.name}');
        await player.setAudioContext(_contexto);
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource('sons/${som.arquivo}'));
        _players[som] = player;
      } catch (e) {
        debugPrint('Sons: não carregou ${som.arquivo}: $e');
      }
    }
  }

  static void tocar(Som som) {
    final player = _players[som];
    if (player == null) return;
    // Recomeça do início, mesmo que o som anterior ainda esteja tocando.
    player.stop().then((_) => player.resume()).catchError((Object e) {
      debugPrint('Sons: falha ao tocar ${som.arquivo}: $e');
    });
  }
}
