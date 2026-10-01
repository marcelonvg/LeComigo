# Biblioteca de textos — design

Data: 2026-10-01 · Status: aprovado em conversa, aguardando revisão desta spec

## Objetivo

Substituir o texto único fixo ("O gato curioso") por uma biblioteca de textos
originais organizada por ano escolar, que o professor escolhe antes de entregar
o aparelho à criança.

## Decisões

| Tema | Decisão |
|---|---|
| Origem dos textos | Pacote fixo no app, textos originais (sem direitos de terceiros) |
| Quantidade | 1º ao 5º ano, 3 textos por ano (15 no total) |
| Quem escolhe | O professor, antes; a criança não vê a lista |
| Armazenamento | Lista `const` em Dart (sem JSON, sem sqflite) |
| Persistência da escolha | Só em memória, enquanto o app estiver aberto |

Rejeitados: JSON em assets (carga assíncrona sem ganho, ninguém edita fora do
código) e sqflite com carga inicial (só faz sentido com textos criados pelo
professor; o sqflite entra na parte 4, histórico).

## Dados — `lib/data/biblioteca.dart`

```dart
class TextoBiblioteca {
  const TextoBiblioteca({required this.id, required this.ano, required this.titulo, required this.conteudo});
  final String id;       // estável, ex.: '1-gato-curioso'
  final int ano;         // 1 a 5
  final String titulo;
  final String conteudo;
}

const biblioteca = <TextoBiblioteca>[/* 15 textos */];

List<TextoBiblioteca> textosDoAno(int ano);
```

- O nome evita conflito com o widget `TextoLeitura`.
- O `id` é o vínculo futuro com o histórico (parte 4): nunca muda depois de publicado.
- "O gato curioso" passa a ser um dos textos do 1º ano (id `1-gato-curioso`);
  `lib/data/textos_exemplo.dart` é removido.

### Conteúdo

Textos originais com temas do cotidiano infantil (bichos, escola, família,
natureza). Faixas de tamanho, em palavras contadas por `tokenizar`:

| Ano | Palavras | Características |
|---|---|---|
| 1º | 25–40 | frases curtas, sílabas simples |
| 2º | 45–65 | frases um pouco mais longas, diálogo simples |
| 3º | 70–95 | dois parágrafos, mais pontuação |
| 4º | 100–125 | vocabulário mais variado |
| 5º | 130–160 | períodos compostos, palavras mais longas |

Toda palavra precisa existir no vocabulário do modelo Vosk; palavra fora do
vocabulário é descartada da grammar e nunca seria reconhecida (sempre "trocada").

## Fluxo e telas

```
Splash → Biblioteca (professor) → Leitura (personagem → contagem → ler → resultado)
            ↑──────────── voltar do sistema ────────────┘
```

### `lib/screens/biblioteca/biblioteca_screen.dart` (nova)

- Título "Escolha o texto" e a linha "Para o professor: escolha e entregue o
  aparelho à criança".
- Seletor de ano: 5 chips (1º a 5º) no estilo 3D dos cartões de personagem;
  começa no 1º ano.
- Lista de cartões do ano: título, início do texto (2 linhas) e número de palavras.
- Tocar no cartão faz `push` da tela de leitura com o texto escolhido.
- O ano selecionado vive no estado da tela; ao voltar da leitura, continua o mesmo.

### Tela de leitura

- `LeituraScreen` recebe `TextoBiblioteca` em vez de `titulo` + `texto`. A
  lógica (`LeituraController`) não muda.
- Sem botão de voltar na tela (a criança não sai sem querer); o retorno à
  biblioteca é pelo voltar do sistema. Voltar durante a leitura já cancela o
  microfone (`dispose` do controller).

### `lib/app.dart`

A splash abre a `BibliotecaScreen` em vez da `LeituraScreen`.

## Testes

### `test/biblioteca_test.dart`

- **Vocabulário**: abre `assets/models/vosk-model-small-pt-0.3.zip` (pacote
  `archive`, dev_dependency), lê a tabela de símbolos embutida em `Gr.fst`
  (após o nome `.../words.txt`: int64 próxima chave, int64 tamanho, e para cada
  símbolo: int32 tamanho, bytes UTF-8, int64 chave) e confere todas as palavras
  de `palavrasDaGramatica(conteudo)` de cada texto. A falha lista palavra e texto.
- Ids únicos; 3 textos por ano; número de palavras na faixa do ano; título e
  conteúdo não vazios.

### `test/biblioteca_screen_test.dart`

- Abre mostrando os títulos do 1º ano.
- Tocar no chip do 3º ano mostra os títulos do 3º.
- Tocar num cartão abre a `LeituraScreen` com aquele título (Vosk falso via Provider).

### Existentes

Ajustar os que usam `titulo`/`texto` soltos; os 46 testes atuais continuam passando.

## Fora do escopo

- Professor criar ou editar textos.
- Salvar o ano/texto escolhido entre aberturas do app.
- Trocar de criança entre leituras ("Ler de novo" mantém o personagem): resolvido
  com o cadastro de alunos (parte 4).
