// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get inicioEscolhaIdioma => 'Choose your language';

  @override
  String get inicioEntrar => 'Enter';

  @override
  String get inicioCarregando => 'Loading...';

  @override
  String get inicioErroModelo =>
      'Could not prepare speech recognition. Please try again.';

  @override
  String get splashCarregando => 'Loading';

  @override
  String get splashErro => 'Could not prepare speech recognition.';

  @override
  String get tentarDeNovo => 'Try again';

  @override
  String get bibliotecaTitulo => 'Choose a text';

  @override
  String get bibliotecaSubtitulo =>
      'For the teacher: choose a text and hand the device to the child.';

  @override
  String anoNumero(String ano) {
    String _temp0 = intl.Intl.selectLogic(ano, {
      '1': '1st',
      '2': '2nd',
      '3': '3rd',
      'other': '${ano}th',
    });
    return '$_temp0';
  }

  @override
  String get anoPalavra => 'grade';

  @override
  String anoCompleto(String ano) {
    String _temp0 = intl.Intl.selectLogic(ano, {
      '1': '1st grade',
      '2': '2nd grade',
      '3': '3rd grade',
      'other': '${ano}th grade',
    });
    return '$_temp0';
  }

  @override
  String palavras(int quantidade) {
    String _temp0 = intl.Intl.pluralLogic(
      quantidade,
      locale: localeName,
      other: '$quantidade words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String get erroSemPermissao =>
      'I need the microphone to hear the reading. Allow it in the device settings.';

  @override
  String get erroMicrofone => 'Couldn\'t turn on the microphone. Try again.';

  @override
  String get continuar => 'Continue';

  @override
  String get comecarLeitura => 'Start reading';

  @override
  String get terminei => 'I\'m done';

  @override
  String get dadosReconhecimento => 'Recognition data';

  @override
  String get mascotePronto => 'Shall we read together?';

  @override
  String get mascoteContagem => 'Here we go!';

  @override
  String get mascoteLendo => 'Read out loud!';

  @override
  String get mascoteLeuBem => 'You read really well!';

  @override
  String get mascoteNaoOuvi => 'Hmm, I couldn\'t hear you well...';

  @override
  String get prepareSe => 'Get ready!';

  @override
  String get quemVaiLer => 'Who will read with you?';

  @override
  String get toqueParaEscolher => 'Tap to choose your reading buddy';

  @override
  String get menino => 'Boy';

  @override
  String get menina => 'Girl';

  @override
  String get parcialAoVivo => 'Partial (live)';

  @override
  String get finalPalavraTempo => 'Final (word and time)';

  @override
  String get fraseTresEstrelas => 'Amazing reading! You\'re a star!';

  @override
  String get fraseDuasEstrelas => 'Very good! Keep practicing.';

  @override
  String get fraseUmaEstrela => 'Nice! Shall we read more often?';

  @override
  String get leituraConcluida => 'Reading complete!';

  @override
  String get naoConseguiOuvir => 'I couldn\'t hear you';

  @override
  String get tenteDeNovoPerto =>
      'Shall we try again? Speak close to the device.';

  @override
  String get lerDeNovo => 'Read again';

  @override
  String get verDetalhes => 'See details';

  @override
  String estrelas(int quantidade) {
    return '$quantidade of 3 stars';
  }

  @override
  String get soUmInstante => 'Just a moment...';

  @override
  String get estouOuvindo => 'I\'m listening!\nRead calmly.';

  @override
  String get resultadoTitulo => 'Reading result';

  @override
  String get precisao => 'Accuracy';

  @override
  String get tempo => 'Time';

  @override
  String get certas => 'Correct';

  @override
  String get trocadas => 'Substituted';

  @override
  String get puladas => 'Skipped';

  @override
  String get acrescentadas => 'Added';

  @override
  String get palavrasCorretasPorMinuto => 'words correct per minute';

  @override
  String get statusCerta => 'correct';

  @override
  String get statusTrocada => 'substituted';

  @override
  String get statusPulada => 'skipped';

  @override
  String get statusNaoLida => 'not read';
}
