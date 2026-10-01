// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get inicioEscolhaIdioma => 'Escolha o idioma';

  @override
  String get inicioEntrar => 'Entrar';

  @override
  String get inicioCarregando => 'Carregando...';

  @override
  String get inicioErroModelo =>
      'Não foi possível preparar o reconhecimento de voz. Tente de novo.';

  @override
  String get splashCarregando => 'Carregando';

  @override
  String get splashErro => 'Não foi possível preparar o reconhecimento de voz.';

  @override
  String get tentarDeNovo => 'Tentar de novo';

  @override
  String get bibliotecaTitulo => 'Escolha o texto';

  @override
  String get bibliotecaSubtitulo =>
      'Para o professor: escolha e entregue o aparelho à criança.';

  @override
  String anoNumero(String ano) {
    return '$anoº';
  }

  @override
  String get anoPalavra => 'ano';

  @override
  String anoCompleto(String ano) {
    return '$anoº ano';
  }

  @override
  String palavras(int quantidade) {
    String _temp0 = intl.Intl.pluralLogic(
      quantidade,
      locale: localeName,
      other: '$quantidade palavras',
      one: '1 palavra',
    );
    return '$_temp0';
  }

  @override
  String get erroSemPermissao =>
      'Preciso do microfone para ouvir a leitura. Libere a permissão nas configurações do aparelho.';

  @override
  String get erroMicrofone =>
      'Não foi possível ligar o microfone. Tente de novo.';

  @override
  String get continuar => 'Continuar';

  @override
  String get comecarLeitura => 'Começar a leitura';

  @override
  String get terminei => 'Terminei';

  @override
  String get dadosReconhecimento => 'Dados do reconhecimento';

  @override
  String get mascotePronto => 'Vamos ler juntos?';

  @override
  String get mascoteContagem => 'Já vai começar!';

  @override
  String get mascoteLendo => 'Leia em voz alta!';

  @override
  String get mascoteLeuBem => 'Você leu muito bem!';

  @override
  String get mascoteNaoOuvi => 'Hum, não ouvi direito...';

  @override
  String get prepareSe => 'Prepare-se!';

  @override
  String get quemVaiLer => 'Quem vai ler com você?';

  @override
  String get toqueParaEscolher => 'Toque para escolher seu amigo de leitura';

  @override
  String get menino => 'Menino';

  @override
  String get menina => 'Menina';

  @override
  String get parcialAoVivo => 'Parcial (ao vivo)';

  @override
  String get finalPalavraTempo => 'Final (palavra e tempo)';

  @override
  String get fraseTresEstrelas => 'Leitura incrível! Você é fera!';

  @override
  String get fraseDuasEstrelas => 'Muito bem! Continue praticando.';

  @override
  String get fraseUmaEstrela => 'Boa! Vamos ler mais vezes?';

  @override
  String get leituraConcluida => 'Leitura concluída!';

  @override
  String get naoConseguiOuvir => 'Não consegui ouvir';

  @override
  String get tenteDeNovoPerto =>
      'Vamos tentar de novo? Fale perto do aparelho.';

  @override
  String get lerDeNovo => 'Ler de novo';

  @override
  String get verDetalhes => 'Ver detalhes';

  @override
  String estrelas(int quantidade) {
    return '$quantidade de 3 estrelas';
  }

  @override
  String get soUmInstante => 'Só um instante...';

  @override
  String get estouOuvindo => 'Estou ouvindo!\nLeia com calma.';

  @override
  String get resultadoTitulo => 'Resultado da leitura';

  @override
  String get precisao => 'Precisão';

  @override
  String get tempo => 'Tempo';

  @override
  String get certas => 'Certas';

  @override
  String get trocadas => 'Trocadas';

  @override
  String get puladas => 'Puladas';

  @override
  String get acrescentadas => 'Acrescentadas';

  @override
  String get palavrasCorretasPorMinuto => 'palavras corretas por minuto';

  @override
  String get statusCerta => 'certa';

  @override
  String get statusTrocada => 'trocada';

  @override
  String get statusPulada => 'pulada';

  @override
  String get statusNaoLida => 'não lida';
}
