import 'package:flutter/material.dart';
import '../enums/perfil_usuario.dart';
import '../enums/status_op.dart';
import '../models/op.dart';
import '../models/usuario.dart';
import '../services/op_service.dart';
import 'ajustar_perda_palete_screen.dart';
import 'editar_palete_screen.dart';
import 'historico_op_screen.dart';
import 'scanner_palete_screen.dart';

class DetalheOPScreen extends StatefulWidget {
  final OP op;
  final Usuario usuario;

  const DetalheOPScreen({
    super.key,
    required this.op,
    required this.usuario,
  });

  @override
  State<DetalheOPScreen> createState() => _DetalheOPScreenState();
}

class _DetalheOPScreenState extends State<DetalheOPScreen> {
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController quantidadeQuebraController =
      TextEditingController();
  final TextEditingController motivoReaberturaController =
      TextEditingController();

  final OPService opService = OPService();

  bool isQuebra = false;

  String textoStatus(StatusOP status) {
    switch (status) {
      case StatusOP.emAndamento:
        return 'Em andamento';
      case StatusOP.finalizada:
        return 'Finalizada';
      case StatusOP.reaberta:
        return 'Reaberta';
      case StatusOP.emRevisao:
        return 'Em revisão';
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) return '-';
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }

  bool get podeEditar =>
    (widget.usuario.perfil == PerfilUsuario.apontamentoOnduladeira ||
        widget.usuario.perfil == PerfilUsuario.apontamentoConversao) &&
    widget.op.status != StatusOP.finalizada;

  bool get podeReabrir =>
      (widget.usuario.perfil == PerfilUsuario.apontamentoOnduladeira ||
          widget.usuario.perfil == PerfilUsuario.apontamentoConversao) &&
      widget.op.status == StatusOP.finalizada;

  void salvarPaleteManual() async {
    final numero = numeroController.text.trim();
    final quantidadeQuebra = quantidadeQuebraController.text.trim();

    if (numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o número do palete')),
      );
      return;
    }

    if (isQuebra && quantidadeQuebra.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a quantidade da quebra')),
      );
      return;
    }

    try {
      await opService.adicionarPalete(
        op: widget.op,
        numero: numero,
        quebra: isQuebra,
        quantidadeQuebra: isQuebra ? quantidadeQuebra : null,
        usuario: widget.usuario,
      );

      setState(() {
        numeroController.clear();
        quantidadeQuebraController.clear();
        isQuebra = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palete registrado com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> abrirScannerPalete() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScannerPaleteScreen(),
      ),
    );

    if (resultado != null && resultado is String) {
      await mostrarPopupRegistroPalete(resultado);
    }
  }

  Future<void> mostrarPopupRegistroPalete(String numeroPalete) async {
    bool quebra = false;
    final TextEditingController quantidadeQuebraPopupController =
        TextEditingController();

    final quantidadePadrao = opService.quantidadePadraoPorOnda(widget.op.onda);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return AlertDialog(
              title: const Text('Registrar Palete'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Palete identificado: $numeroPalete'),
                    const SizedBox(height: 8),
                    Text('Onda da OP: ${opService.textoOnda(widget.op.onda)}'),
                    const SizedBox(height: 8),
                    Text('Quantidade padrão: $quantidadePadrao'),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Palete de Quebra'),
                      value: quebra,
                      onChanged: (value) {
                        setStatePopup(() {
                          quebra = value;
                        });
                      },
                    ),
                    if (quebra)
                      TextField(
                        controller: quantidadeQuebraPopupController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade da Quebra',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Se salvar como completo, a quantidade padrão será usada automaticamente.',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await opService.adicionarPalete(
                        op: widget.op,
                        numero: numeroPalete,
                        quebra: quebra,
                        quantidadeQuebra: quebra
                            ? quantidadeQuebraPopupController.text.trim()
                            : null,
                        usuario: widget.usuario,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      this.setState(() {});

                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Palete registrado com sucesso'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void finalizarOP() async {
    try {
      await opService.finalizarOP(
        op: widget.op,
        usuario: widget.usuario,
      );

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OP finalizada com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void reabrirOP() async {
    final motivo = motivoReaberturaController.text.trim();

    try {
      await opService.reabrirOP(
        op: widget.op,
        motivo: motivo,
        usuario: widget.usuario,
      );

      setState(() {
        motivoReaberturaController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OP reaberta com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> abrirEdicaoPalete(palete) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarPaleteScreen(
          op: widget.op,
          palete: palete,
          usuario: widget.usuario,
        ),
      ),
    );

    if (resultado == true) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palete editado com sucesso')),
      );
    }
  }

  Future<void> abrirAjustePerda(palete) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AjustarPerdaPaleteScreen(
          op: widget.op,
          palete: palete,
          usuario: widget.usuario,
        ),
      ),
    );

    if (resultado == true) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perda ajustada com sucesso')),
      );
    }
  }

  void abrirHistorico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoricoOPScreen(op: widget.op),
      ),
    );
  }

  Widget campo(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    numeroController.dispose();
    quantidadeQuebraController.dispose();
    motivoReaberturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.op;
    final totalChapas = opService.calcularTotalChapas(op);
    final quantidadePadrao = opService.quantidadePadraoPorOnda(op.onda);

    return Scaffold(
      appBar: AppBar(
        title: Text('OP ${op.ordem}'),
        actions: [
          IconButton(
            onPressed: abrirHistorico,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${op.cliente}'),
            Text('Medida: ${op.largura} x ${op.comprimento}'),
            Text('Onda: ${opService.textoOnda(op.onda)}'),
            Text('Qtd. padrão por palete completo: $quantidadePadrao'),
            Text('Ordem: ${op.ordem}'),
            Text('FT: ${op.ft}'),
            Text('QP: ${op.qp}'),
            Text('Status: ${textoStatus(op.status)}'),
            Text('Paletes registrados: ${op.paletes.length}'),
            Text(
              'Total de chapas: $totalChapas',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (op.ultimoMotivoReabertura.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Último motivo de reabertura: ${op.ultimoMotivoReabertura}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Data da última reabertura: ${formatarData(op.dataUltimaReabertura)}',
              ),
            ],
            const SizedBox(height: 20),
            if (podeEditar) ...[
              const Text(
                'Registrar Palete Manualmente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              campo('Número do Palete', numeroController),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: abrirScannerPalete,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Ler código de barras'),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Palete de Quebra'),
                value: isQuebra,
                onChanged: (value) {
                  setState(() {
                    isQuebra = value;
                    if (!isQuebra) {
                      quantidadeQuebraController.clear();
                    }
                  });
                },
              ),
              if (!isQuebra)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Palete completo usará automaticamente $quantidadePadrao chapas.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              if (isQuebra)
                campo(
                  'Quantidade da Quebra',
                  quantidadeQuebraController,
                  keyboardType: TextInputType.number,
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: salvarPaleteManual,
                  child: const Text('Salvar Palete Manualmente'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: finalizarOP,
                  child: const Text('Finalizar OP'),
                ),
              ),
            ],
            if (podeReabrir) ...[
              const SizedBox(height: 16),
              campo('Motivo da Reabertura', motivoReaberturaController),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: reabrirOP,
                  child: const Text('Reabrir OP'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Paletes Registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (op.paletes.isEmpty)
              const Text('Nenhum palete registrado ainda.')
            else
              ...op.paletes.map(
                (p) => Card(
                  child: ListTile(
                    title: Text('Palete ${p.numero}'),
                    subtitle: Text(
                      'Tipo: ${p.quebra ? "Quebra" : "Completo"}\n'
                      'Quantidade original: ${p.quantidadeOriginal}\n'
                      'Quantidade perdida: ${p.quantidadePerdida}\n'
                      'Saldo atual: ${p.saldoAtual}\n'
                      'Último motivo de ajuste: '
                      '${p.ultimoMotivoAjuste.isEmpty ? "-" : p.ultimoMotivoAjuste}\n'
                      'Data do último ajuste: ${formatarData(p.dataUltimoAjuste)}',
                    ),
                    trailing: podeEditar
                        ? Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => abrirEdicaoPalete(p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.warning_amber_rounded),
                                onPressed: () => abrirAjustePerda(p),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}