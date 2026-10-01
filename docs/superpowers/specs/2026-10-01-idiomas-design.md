# Idiomas (português, inglês, espanhol) — design

Data: 2026-10-01 · Status: aprovado em conversa, aguardando revisão desta spec

## Objetivo

O app passa a funcionar em português, inglês e espanhol. Toda vez que o app
abre, uma tela inicial mostra o idioma atual e deixa trocá-lo antes de
entrar. A escolha vale para as telas **e** para a leitura (textos e
reconhecimento de voz). O app continua 100% offline.

## Decisões

| Tema | Decisão |
|---|---|
| Modelos de voz | Os 3 modelos Vosk vão no APK (~110 MB no total) |
| Quando escolher | Em toda abertura, numa tela inicial com as 3 bandeiras (a salva já marcada) e o botão "Entrar" |
| Escopo da escolha | Uma escolha só: idioma das telas = idioma da leitura |
| Textos en/es | 15 textos originais por idioma (3 por ano), escritos pelo Claude e revisados pelo usuário |
| Tradução das telas | `gen-l10n` do Flutter com arquivos ARB |
| Persistência | `shared_preferences` (dependência nova) |
| Modelos na memória | Só um por vez; trocar de idioma libera o atual e carrega o novo |

Rejeitados:
- Escolher só na 1ª abertura e trocar por um botão na biblioteca: o usuário
  quer a opção visível antes de entrar.
- Bandeiras na própria splash: a janela para trocar seria curta, porque a
  splash entra sozinha quando o modelo termina de carregar.
- Botão de idioma também na biblioteca: fica de fora por enquanto, porque a
  troca já acontece na tela inicial. Pode entrar depois, reusando o mesmo
  seletor.
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

- `Idioma atual`: o idioma salvo. Sem nada salvo (1ª abertura), usa o idioma
  do aparelho se for pt, en ou es; senão, pt.
- `Future<void> carregar()`: lê o código salvo em `shared_preferences`.
- `Future<void> escolher(Idioma)`: salva e notifica. Como o `MaterialApp`
  escuta o controller, a tela inicial muda de idioma na hora em que a pessoa
  toca numa bandeira.

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

```
splash (carrega o modelo do idioma atual) → tela inicial → biblioteca
```

**Splash:** igual a hoje, mas carrega o modelo do idioma atual e, no fim, vai
para a `InicioScreen` em vez da biblioteca. Ela não mostra texto traduzível
(o título "Lê Comigo" é nome de marca e fica igual nos 3 idiomas).

**`InicioScreen` (nova, `lib/screens/inicio/`):** aparece em toda abertura.
- Mascote e título "Lê Comigo".
- Três cartões de idioma, no estilo dos botões 3D já existentes, cada um com
  bandeira e nome no próprio idioma ("Português", "English", "Español"). O
  idioma atual aparece marcado.
- Botão grande "Entrar" (traduzido: "Entrar", "Enter", "Entrar").

Comportamento:
1. Tocar num cartão chama `IdiomaController.escolher` e a tela inteira muda
   para aquele idioma na hora. Só a marcação e os textos mudam; o modelo de
   voz ainda não é trocado.
2. Tocar em "Entrar" chama `VoskService.carregarModelo(idiomaAtual)`.
   - Se for o mesmo idioma que a splash carregou, não faz nada e vai direto
     para a biblioteca.
   - Se for outro idioma, o botão mostra um indicador de carregamento (a
     primeira carga de um idioma leva alguns segundos para descompactar),
     enquanto os cartões e o botão ficam desabilitados. Ao terminar, vai para
     a biblioteca.
3. A navegação para a biblioteca usa `pushReplacement`, como a splash faz
   hoje.

**Falha ao carregar o modelo:**
- Na splash, aparece o "tentar de novo" que já existe.
- Na tela inicial, a tela continua aberta com uma mensagem de erro, e
  "Entrar" pode ser tocado de novo. A pessoa também pode voltar para outro
  idioma.

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
  - A splash leva à tela inicial, com o idioma atual marcado.
  - Tocar numa bandeira troca as frases da tela inicial na hora.
  - "Entrar" leva à biblioteca, que mostra os textos do idioma escolhido.
  - "Entrar" com outro idioma carrega o modelo novo, e a tela trata a falha
    com mensagem de erro.
  - 1ª abertura sem nada salvo: usa o idioma do aparelho (pt, en ou es) ou
    pt.
- Os testes de widget que já existem passam a envolver as telas com o
  `AppLocalizations` em pt.
- Os testes no aparelho ficam com o usuário. No fim, entrego um checklist:
  ler um texto em cada idioma, trocar de idioma na tela inicial, abrir pela
  primeira vez sem dados salvos e ver o tamanho do APK.

## Fora de escopo

- Idioma das telas diferente do idioma da leitura.
- Baixar modelos ou textos pela internet.
- Histórico de leituras, que é outra parte do projeto. Os ids estáveis já
  deixam essa parte preparada.
