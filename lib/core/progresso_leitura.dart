// Estimativa ao vivo de até onde a criança já leu. Dart puro.

/// Quantas palavras do texto a criança já alcançou, para o destaque ao vivo.
///
/// É uma estimativa rápida e tolerante; a contagem oficial (acertos, trocas,
/// omissões) vem do alinhamento, ao final da leitura.
///
/// Para cada palavra reconhecida, procura-a nas próximas [janela] palavras
/// esperadas a partir da posição atual. Achou: avança até ela (as puladas
/// contam como alcançadas). Não achou (troca ou ruído): fica onde está.
///
/// As duas listas devem vir normalizadas por `tokenizar`.
int palavrasAlcancadas(
  List<String> esperadas,
  List<String> reconhecidas, {
  int janela = 3,
}) {
  var posicao = 0;
  for (final palavra in reconhecidas) {
    if (palavra == 'unk') continue; // "[unk]" do Vosk depois de tokenizar
    for (var k = 0; k < janela && posicao + k < esperadas.length; k++) {
      if (esperadas[posicao + k] == palavra) {
        posicao += k + 1;
        break;
      }
    }
  }
  return posicao;
}
