import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @inicioEscolhaIdioma.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma'**
  String get inicioEscolhaIdioma;

  /// No description provided for @inicioEntrar.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get inicioEntrar;

  /// No description provided for @inicioCarregando.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get inicioCarregando;

  /// No description provided for @inicioErroModelo.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível preparar o reconhecimento de voz. Tente de novo.'**
  String get inicioErroModelo;

  /// No description provided for @splashCarregando.
  ///
  /// In pt, this message translates to:
  /// **'Carregando'**
  String get splashCarregando;

  /// No description provided for @splashErro.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível preparar o reconhecimento de voz.'**
  String get splashErro;

  /// No description provided for @tentarDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get tentarDeNovo;

  /// No description provided for @bibliotecaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o texto'**
  String get bibliotecaTitulo;

  /// No description provided for @bibliotecaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Para o professor: escolha e entregue o aparelho à criança.'**
  String get bibliotecaSubtitulo;

  /// No description provided for @anoNumero.
  ///
  /// In pt, this message translates to:
  /// **'{ano}º'**
  String anoNumero(String ano);

  /// No description provided for @anoPalavra.
  ///
  /// In pt, this message translates to:
  /// **'ano'**
  String get anoPalavra;

  /// No description provided for @anoCompleto.
  ///
  /// In pt, this message translates to:
  /// **'{ano}º ano'**
  String anoCompleto(String ano);

  /// No description provided for @palavras.
  ///
  /// In pt, this message translates to:
  /// **'{quantidade, plural, =1{1 palavra} other{{quantidade} palavras}}'**
  String palavras(int quantidade);

  /// No description provided for @erroSemPermissao.
  ///
  /// In pt, this message translates to:
  /// **'Preciso do microfone para ouvir a leitura. Libere a permissão nas configurações do aparelho.'**
  String get erroSemPermissao;

  /// No description provided for @erroMicrofone.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ligar o microfone. Tente de novo.'**
  String get erroMicrofone;

  /// No description provided for @continuar.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// No description provided for @comecarLeitura.
  ///
  /// In pt, this message translates to:
  /// **'Começar a leitura'**
  String get comecarLeitura;

  /// No description provided for @terminei.
  ///
  /// In pt, this message translates to:
  /// **'Terminei'**
  String get terminei;

  /// No description provided for @dadosReconhecimento.
  ///
  /// In pt, this message translates to:
  /// **'Dados do reconhecimento'**
  String get dadosReconhecimento;

  /// No description provided for @mascotePronto.
  ///
  /// In pt, this message translates to:
  /// **'Vamos ler juntos?'**
  String get mascotePronto;

  /// No description provided for @mascoteContagem.
  ///
  /// In pt, this message translates to:
  /// **'Já vai começar!'**
  String get mascoteContagem;

  /// No description provided for @mascoteLendo.
  ///
  /// In pt, this message translates to:
  /// **'Leia em voz alta!'**
  String get mascoteLendo;

  /// No description provided for @mascoteLeuBem.
  ///
  /// In pt, this message translates to:
  /// **'Você leu muito bem!'**
  String get mascoteLeuBem;

  /// No description provided for @mascoteNaoOuvi.
  ///
  /// In pt, this message translates to:
  /// **'Hum, não ouvi direito...'**
  String get mascoteNaoOuvi;

  /// No description provided for @prepareSe.
  ///
  /// In pt, this message translates to:
  /// **'Prepare-se!'**
  String get prepareSe;

  /// No description provided for @quemVaiLer.
  ///
  /// In pt, this message translates to:
  /// **'Quem vai ler com você?'**
  String get quemVaiLer;

  /// No description provided for @toqueParaEscolher.
  ///
  /// In pt, this message translates to:
  /// **'Toque para escolher seu amigo de leitura'**
  String get toqueParaEscolher;

  /// No description provided for @menino.
  ///
  /// In pt, this message translates to:
  /// **'Menino'**
  String get menino;

  /// No description provided for @menina.
  ///
  /// In pt, this message translates to:
  /// **'Menina'**
  String get menina;

  /// No description provided for @parcialAoVivo.
  ///
  /// In pt, this message translates to:
  /// **'Parcial (ao vivo)'**
  String get parcialAoVivo;

  /// No description provided for @finalPalavraTempo.
  ///
  /// In pt, this message translates to:
  /// **'Final (palavra e tempo)'**
  String get finalPalavraTempo;

  /// No description provided for @fraseTresEstrelas.
  ///
  /// In pt, this message translates to:
  /// **'Leitura incrível! Você é fera!'**
  String get fraseTresEstrelas;

  /// No description provided for @fraseDuasEstrelas.
  ///
  /// In pt, this message translates to:
  /// **'Muito bem! Continue praticando.'**
  String get fraseDuasEstrelas;

  /// No description provided for @fraseUmaEstrela.
  ///
  /// In pt, this message translates to:
  /// **'Boa! Vamos ler mais vezes?'**
  String get fraseUmaEstrela;

  /// No description provided for @leituraConcluida.
  ///
  /// In pt, this message translates to:
  /// **'Leitura concluída!'**
  String get leituraConcluida;

  /// No description provided for @naoConseguiOuvir.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui ouvir'**
  String get naoConseguiOuvir;

  /// No description provided for @tenteDeNovoPerto.
  ///
  /// In pt, this message translates to:
  /// **'Vamos tentar de novo? Fale perto do aparelho.'**
  String get tenteDeNovoPerto;

  /// No description provided for @lerDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Ler de novo'**
  String get lerDeNovo;

  /// No description provided for @verDetalhes.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get verDetalhes;

  /// No description provided for @estrelas.
  ///
  /// In pt, this message translates to:
  /// **'{quantidade} de 3 estrelas'**
  String estrelas(int quantidade);

  /// No description provided for @soUmInstante.
  ///
  /// In pt, this message translates to:
  /// **'Só um instante...'**
  String get soUmInstante;

  /// No description provided for @estouOuvindo.
  ///
  /// In pt, this message translates to:
  /// **'Estou ouvindo!\nLeia com calma.'**
  String get estouOuvindo;

  /// No description provided for @resultadoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Resultado da leitura'**
  String get resultadoTitulo;

  /// No description provided for @precisao.
  ///
  /// In pt, this message translates to:
  /// **'Precisão'**
  String get precisao;

  /// No description provided for @tempo.
  ///
  /// In pt, this message translates to:
  /// **'Tempo'**
  String get tempo;

  /// No description provided for @certas.
  ///
  /// In pt, this message translates to:
  /// **'Certas'**
  String get certas;

  /// No description provided for @trocadas.
  ///
  /// In pt, this message translates to:
  /// **'Trocadas'**
  String get trocadas;

  /// No description provided for @puladas.
  ///
  /// In pt, this message translates to:
  /// **'Puladas'**
  String get puladas;

  /// No description provided for @acrescentadas.
  ///
  /// In pt, this message translates to:
  /// **'Acrescentadas'**
  String get acrescentadas;

  /// No description provided for @palavrasCorretasPorMinuto.
  ///
  /// In pt, this message translates to:
  /// **'palavras corretas por minuto'**
  String get palavrasCorretasPorMinuto;

  /// No description provided for @statusCerta.
  ///
  /// In pt, this message translates to:
  /// **'certa'**
  String get statusCerta;

  /// No description provided for @statusTrocada.
  ///
  /// In pt, this message translates to:
  /// **'trocada'**
  String get statusTrocada;

  /// No description provided for @statusPulada.
  ///
  /// In pt, this message translates to:
  /// **'pulada'**
  String get statusPulada;

  /// No description provided for @statusNaoLida.
  ///
  /// In pt, this message translates to:
  /// **'não lida'**
  String get statusNaoLida;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
