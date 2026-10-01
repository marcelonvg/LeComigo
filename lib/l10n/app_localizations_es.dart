// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get inicioEscolhaIdioma => 'Elige el idioma';

  @override
  String get inicioEntrar => 'Entrar';

  @override
  String get inicioCarregando => 'Cargando...';

  @override
  String get inicioErroModelo =>
      'No se pudo preparar el reconocimiento de voz. Inténtalo de nuevo.';

  @override
  String get splashCarregando => 'Cargando';

  @override
  String get bibliotecaTitulo => 'Elige el texto';

  @override
  String get bibliotecaSubtitulo =>
      'Para el docente: elige y entrega el dispositivo al niño.';

  @override
  String anoNumero(String ano) {
    return '$ano.º';
  }

  @override
  String get anoPalavra => 'grado';

  @override
  String anoCompleto(String ano) {
    return '$ano.º grado';
  }

  @override
  String palavras(int quantidade) {
    String _temp0 = intl.Intl.pluralLogic(
      quantidade,
      locale: localeName,
      other: '$quantidade palabras',
      one: '1 palabra',
    );
    return '$_temp0';
  }

  @override
  String get erroSemPermissao =>
      'Necesito el micrófono para escuchar la lectura. Activa el permiso en los ajustes del dispositivo.';

  @override
  String get erroMicrofone =>
      'No se pudo encender el micrófono. Inténtalo de nuevo.';

  @override
  String get continuar => 'Continuar';

  @override
  String get comecarLeitura => 'Empezar a leer';

  @override
  String get terminei => 'Terminé';

  @override
  String get dadosReconhecimento => 'Datos del reconocimiento';

  @override
  String get mascotePronto => '¿Leemos juntos?';

  @override
  String get mascoteContagem => '¡Ya va a empezar!';

  @override
  String get mascoteLendo => '¡Lee en voz alta!';

  @override
  String get mascoteLeuBem => '¡Leíste muy bien!';

  @override
  String get mascoteNaoOuvi => 'Mmm, no te escuché bien...';

  @override
  String get prepareSe => '¡Prepárate!';

  @override
  String get quemVaiLer => '¿Quién va a leer contigo?';

  @override
  String get toqueParaEscolher => 'Toca para elegir a tu amigo de lectura';

  @override
  String get menino => 'Niño';

  @override
  String get menina => 'Niña';

  @override
  String get parcialAoVivo => 'Parcial (en vivo)';

  @override
  String get finalPalavraTempo => 'Final (palabra y tiempo)';

  @override
  String get fraseTresEstrelas => '¡Lectura increíble! ¡Eres genial!';

  @override
  String get fraseDuasEstrelas => '¡Muy bien! Sigue practicando.';

  @override
  String get fraseUmaEstrela => '¡Bien! ¿Leemos más veces?';

  @override
  String get leituraConcluida => '¡Lectura terminada!';

  @override
  String get naoConseguiOuvir => 'No pude escucharte';

  @override
  String get tenteDeNovoPerto =>
      '¿Lo intentamos de nuevo? Habla cerca del dispositivo.';

  @override
  String get lerDeNovo => 'Leer de nuevo';

  @override
  String get verDetalhes => 'Ver detalles';

  @override
  String estrelas(int quantidade) {
    return '$quantidade de 3 estrellas';
  }

  @override
  String get soUmInstante => 'Un momento...';

  @override
  String get estouOuvindo => '¡Te estoy escuchando!\nLee con calma.';

  @override
  String get resultadoTitulo => 'Resultado de la lectura';

  @override
  String get precisao => 'Precisión';

  @override
  String get tempo => 'Tiempo';

  @override
  String get certas => 'Correctas';

  @override
  String get trocadas => 'Cambiadas';

  @override
  String get puladas => 'Omitidas';

  @override
  String get acrescentadas => 'Añadidas';

  @override
  String get palavrasCorretasPorMinuto => 'palabras correctas por minuto';

  @override
  String get statusCerta => 'correcta';

  @override
  String get statusTrocada => 'cambiada';

  @override
  String get statusPulada => 'omitida';

  @override
  String get statusNaoLida => 'no leída';
}
