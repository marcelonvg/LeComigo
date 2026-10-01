# Idiomas (português, inglês, espanhol) — design

Data: 2026-10-01 · Status: aprovado em conversa, aguardando revisão desta spec

## Objetivo

O app passa a funcionar em português, inglês e espanhol. Na primeira abertura
a pessoa escolhe o idioma; a escolha vale para as telas **e** para a leitura
(textos e reconhecimento de voz). Dá para trocar depois. O app continua 100%
offline.

## Decisões

| Tema | Decisão |
|---|---|
| Modelos de voz | Os 3 modelos Vosk vão no APK (~110 MB no total) |
| Quando escolher | Na 1ª abertura; trocar depois por um botão na biblioteca |
| Escopo da escolha | Uma escolha só: idioma das telas = idioma da leitura |
| Textos en/es | 15 textos originais por idioma (3 por ano), escritos pelo Claude e revisados pelo usuário |
| Tradução das telas | `gen-l10n` do Flutter com arquivos ARB |
| Persistência | `shared_preferences` (dependência nova) |
| Modelos na memória | Só um por vez; trocar de idioma libera o atual e carrega o novo |

Rejeitados:
- Baixar o modelo sob demanda, porque quebraria o "offline desde a instalação".
- Um APK por idioma, porque a escolha não seria feita dentro do app.
- Mapa de strings feito à mão, porque não traduz os textos do Material e não
  acusa uma tradução faltando.
- Traduzir os textos atuais, porque a tradução muda o tamanho e a dificuldade
  dos textos.

## Núcleo — `lib/core/idioma.dart` (Dart puro)

```dart
enum Idioma {
  pt(codigo: 'pt', nome: 'Português', modelo: 'assets/models/vosk-model-small-pt-0.3.zip'),
  en(codigo: 'en', nome: 'English',   modelo: 'assets/models/vosk-model-small-en-us-0.15.zip'),
  es(codigo: 'es', nome: 'Español',   modelo: 'assets/models/vosk-model-small-es-0.42.zip');

  final String codigo;  // vira Locale(codigo) na camada Flutter
  final String nome;    // sempre no próprio idioma, na tela de escolha
  final String modelo;  // asset do zip do Vosk

  static Idioma? doCodigo(String? codigo);
}
```

## Estado — `lib/services/idioma_controller.dart`

`ChangeNotifier` fornecido por Provider em `main.dart`, ao lado do `VoskService`.

- `Idioma? atual`: null até haver uma escolha.
- `Future<void> carregar()`: lê o código salvo em `shared_preferences`.
- `Future<void> escolher(Idioma)`: salva e notifica.

`MaterialApp` escuta o controller para definir `locale`,
`supportedLocales`, `localizationsDelegates` e `AppLocalizations.delegate`.

## Reconhecimento — `VoskService`

- `carregarModelo(Idioma idioma)`: se já houver um modelo de **outro** idioma
  carregado, cancela a sessão ativa, faz `dispose` do modelo e carrega o novo.
  Se for o mesmo idioma, não faz nada.
- Expõe `Idioma? idiomaCarregado`.
- A primeira carga de cada idioma descompacta o zip, o que leva alguns
  segundos. As cargas seguintes usam a pasta já extraída. Isso já é feito
  pelo `ModelLoader`.

Os modelos novos ficam em `assets/models/` e são declarados no `pubspec.yaml`.
Antes de seguir, a implementação confirma que `en-us-0.15` e `es-0.42` aceitam
`grammar` e têm `Gr.fst` com tabela de símbolos, que o teste de vocabulário
precisa.

## Fluxo de telas

**Primeira abertura (nenhum idioma salvo):** a splash anima e lê o
controller. Sem idioma, ela vai para `EscolhaIdiomaScreen`. Depois da
escolha, volta ao estado de carregamento da splash, carrega o modelo e vai
para a biblioteca. A splash não mostra texto traduzível antes da escolha
(o título "Lê Comigo" é nome de marca e fica igual nos 3 idiomas).

**Aberturas seguintes:** a splash carrega o modelo do idioma salvo, como hoje.

**Trocar depois:** a `BibliotecaScreen` ganha um botão de idioma na
barra superior, com a bandeira e o código ("PT", "EN", "ES"). Ele abre
`EscolhaIdiomaScreen` em modo troca:

1. A pessoa escolhe um idioma.
2. A tela mostra um indicador de carregamento enquanto o `VoskService`
   carrega o modelo novo.
3. O controller salva a escolha.
4. A tela volta para a biblioteca, que já aparece no idioma novo e com os
   textos dele.

Escolher o idioma atual só fecha a tela.

**`EscolhaIdiomaScreen`:** três cartões grandes, no estilo dos botões 3D já
existentes, com bandeira e nome no próprio idioma, além do mascote. No modo
troca há um botão de voltar.

**Falha ao carregar o modelo:**
- Na splash, aparece o "tentar de novo" que já existe.
- Na troca, o idioma anterior continua salvo, o app recarrega o modelo
  anterior e mostra uma mensagem de erro.

## Textos — `lib/data/`

- `TextoBiblioteca` ganha o campo `final Idioma idioma`.
- `biblioteca.dart` mantém a classe e passa a ter
  `textosDoAno(Idioma idioma, int ano)`, além de
  `const biblioteca = [...bibliotecaPt, ...bibliotecaEn, ...bibliotecaEs]`.
- As listas ficam em `biblioteca_pt.dart` (os 15 textos atuais),
  `biblioteca_en.dart` e `biblioteca_es.dart`.
- **Os ids em português não mudam.** Os novos levam prefixo: `en-1-curious-cat`,
  `es-1-gato-curioso`.
- Os textos novos são originais, com os mesmos temas e o mesmo estilo dos
  atuais (bichos, escola, família, natureza). Usam as mesmas faixas de tamanho
  por ano (palavras contadas por `tokenizar`): 1º 25–40, 2º 45–65, 3º 70–95,
  4º 100–125, 5º 130–160.

## Normalização — `lib/core/normalizacao.dart`

- O apóstrofo entre letras passa a fazer parte da palavra ("don't" e "it's"
  continuam uma palavra só, como no vocabulário do modelo en). O apóstrofo
  tipográfico (’) é convertido para `'` antes.
- Apóstrofo isolado ou na ponta da palavra continua virando separador.
- `¿` e `¡` já viram separador, sem mudança. `ñ` e `ü` já estão cobertos.
- A regra vale para os 3 idiomas. Os textos em português não usam apóstrofo,
  e o teste de vocabulário pega qualquer caso que escape.
- Quem conta palavras com `tokenizar` (`texto_leitura.dart` e
  `resultado_screen.dart`) herda a mudança sem ajustes.

`AvaliacaoLeitura` e `ProgressoLeitura` não mudam porque não dependem de
idioma.

## Telas traduzidas

- `l10n.yaml` na raiz, com os ARB em `lib/l10n/` (`app_pt.arb` como template,
  `app_en.arb` e `app_es.arb`) e a classe gerada `AppLocalizations`.
- Dependências: `flutter_localizations` (SDK) e `intl`, além de
  `generate: true` no `pubspec.yaml`.
- Todas as frases fixas de `lib/screens` e `lib/widgets` passam para os ARB,
  incluindo plurais e interpolações (por exemplo, o rótulo do ano e a
  contagem de palavras).
- Termos por idioma:

| | pt | en | es |
|---|---|---|---|
| Ano escolar | 1º ano | 1st grade | 1.º grado |
| Métrica | PCPM | WCPM | PCPM |

- Os sons (`assets/sons/`) são efeitos sem fala e ficam como estão.
- O PDF do resultado, se tiver frases, também usa `AppLocalizations`.

## Testes

- `test/biblioteca_test.dart`: o teste de vocabulário roda para cada idioma
  com o modelo dele, e o caminho do `Gr.fst` dentro do zip passa a vir do
  `Idioma`. Ele confere ids únicos no conjunto todo, 3 textos por ano em cada
  idioma e as faixas de tamanho.
- `test/normalizacao_test.dart`: apóstrofo ("don't" é uma palavra, `’` é
  convertido, apóstrofo na ponta é removido), `¿`, `¡` e `ñ`.
- `test/idioma_test.dart`: `Idioma.doCodigo` e o `IdiomaController` (salvar e
  ler com `SharedPreferences.setMockInitialValues`).
- Testes de widget:
  - Primeira abertura: a splash leva à escolha de idioma, que leva à biblioteca.
  - A biblioteca mostra os textos do idioma atual.
  - Trocar o idioma muda os textos e as frases da tela.
- Os testes de widget que já existem passam a envolver as telas com o
  `AppLocalizations` em pt.
- Os testes no aparelho ficam com o usuário. No fim, entrego um checklist:
  ler um texto em cada idioma, trocar de idioma, abrir pela primeira vez sem
  dados salvos e ver o tamanho do APK.

## Fora de escopo

- Idioma das telas diferente do idioma da leitura.
- Baixar modelos ou textos pela internet.
- Histórico de leituras, que é outra parte do projeto. Os ids estáveis já
  deixam essa parte preparada.
