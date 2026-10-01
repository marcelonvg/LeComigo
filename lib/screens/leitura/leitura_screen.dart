import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/biblioteca.dart';
import '../../services/vosk_service.dart';
import '../../tema/tema_app.dart';
import '../../widgets/botao_3d.dart';
import '../resultado/resultado_screen.dart';
import 'leitura_controller.dart';
import 'widgets/barra_tempo.dart';
import 'widgets/cabecalho_mascote.dart';
import 'widgets/cartao_texto.dart';
import 'widgets/contagem_regressiva.dart';
import 'widgets/escolha_personagem.dart';
import 'widgets/painel_detalhes.dart';
import 'widgets/painel_fim.dart';
import 'widgets/rodape.dart';
import 'widgets/texto_leitura.dart';

/// Tela em que a criança lê o texto em voz alta.
/// A lógica fica no [LeituraController]; aqui só se monta a tela.
class LeituraScreen extends StatelessWidget {
  const LeituraScreen({super.key, required this.texto});

  final TextoBiblioteca texto;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LeituraController(
        texto: texto.conteudo,
        vosk: context.read<VoskService>(),
      ),
      child: _LeituraView(titulo: texto.titulo),
    );
  }
}

class _LeituraView extends StatelessWidget {
  const _LeituraView({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<LeituraController>();
    final escolhendo = c.fase == FaseLeitura.escolha;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  if (!escolhendo)
                    BarraTempo(
                      decorrido: c.decorrido,
                      duracaoMaxima: c.duracaoMaxima,
                      aoAlternarDetalhes: c.alternarDetalhes,
                    ),
                  Expanded(
                    child: escolhendo
                        ? EscolhaPersonagem(
                            menina: c.menina,
                            aoEscolher: (menina) =>
                                c.escolherPersonagem(menina: menina),
                          )
                        : _Conteudo(titulo: titulo, c: c),
                  ),
                  _Rodape(titulo: titulo, c: c),
                ],
              ),
              if (c.fase == FaseLeitura.contagem)
                ContagemRegressiva(numero: c.contagem),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mascote, texto e (opcional) dados do reconhecimento.
class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.titulo, required this.c});

  final String titulo;
  final LeituraController c;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        CabecalhoMascote(
          fase: c.fase,
          ouviuAlgo: c.ouviuAlgo,
          menina: c.menina ?? false,
          // Antes de começar, tocar no mascote troca o personagem.
          aoTocarMascote: c.fase == FaseLeitura.pronto
              ? c.trocarPersonagem
              : null,
        ),
        const SizedBox(height: 20),
        CartaoTexto(
          titulo: titulo,
          child: TextoLeitura(
            texto: c.texto,
            alcancadas: c.alcancadas,
            ativo: c.fase == FaseLeitura.lendo || c.fase == FaseLeitura.fim,
            marcarAtual: c.fase == FaseLeitura.lendo,
          ),
        ),
        if (c.mostrarDetalhes) ...[
          const SizedBox(height: 16),
          PainelDetalhes(parcial: c.parcial, finais: c.finais),
        ],
      ],
    );
  }
}

/// Pé da tela: o que aparece depende da fase.
class _Rodape extends StatelessWidget {
  const _Rodape({required this.titulo, required this.c});

  final String titulo;
  final LeituraController c;

  static String _mensagem(ErroLeitura erro) => switch (erro) {
    ErroLeitura.semPermissao =>
      'Preciso do microfone para ouvir a leitura. '
          'Libere a permissão nas configurações do aparelho.',
    ErroLeitura.falhaMicrofone =>
      'Não foi possível ligar o microfone. Tente de novo.',
  };

  @override
  Widget build(BuildContext context) {
    return switch (c.fase) {
      FaseLeitura.escolha => Rodape(
        children: [
          Botao3D(
            rotulo: 'Continuar',
            icone: Icons.arrow_forward_rounded,
            aoTocar: c.menina == null ? null : c.confirmarPersonagem,
          ),
        ],
      ),
      FaseLeitura.pronto || FaseLeitura.contagem => Rodape(
        children: [
          if (c.erro != null) ...[
            Text(
              _mensagem(c.erro!),
              textAlign: TextAlign.center,
              style: Estilos.corpo.copyWith(color: Cores.erro),
            ),
            const SizedBox(height: 12),
          ],
          Botao3D(
            rotulo: 'Começar a leitura',
            icone: Icons.mic_rounded,
            aoTocar: c.fase == FaseLeitura.pronto ? c.comecar : null,
          ),
        ],
      ),
      FaseLeitura.lendo => Rodape(
        children: [
          AvisoOuvindo(parando: c.parando),
          const SizedBox(height: 8),
          Botao3D.secundario(
            rotulo: 'Terminei',
            icone: Icons.check_rounded,
            aoTocar: c.parando ? null : c.terminar,
          ),
        ],
      ),
      FaseLeitura.fim => PainelFim(
        ouviu: c.ouviuAlgo,
        estrelas: c.avaliacao?.estrelas ?? 0,
        aoLerDeNovo: c.lerDeNovo,
        aoVerDetalhes: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultadoScreen(
              titulo: titulo,
              texto: c.texto,
              avaliacao: c.avaliacao!,
            ),
          ),
        ),
      ),
    };
  }
}
