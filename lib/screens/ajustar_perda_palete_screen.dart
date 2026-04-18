import 'package:flutter/material.dart';
import '../models/op.dart';
import '../models/palete.dart';
import '../models/usuario.dart';
import '../services/op_service.dart';

class AjustarPerdaPaleteScreen extends StatefulWidget {
  final OP op;
  final Palete palete;
  final Usuario usuario;

  const AjustarPerdaPaleteScreen({
    super.key,
    required this.op,
    required this.palete,
    required this.usuario,
  });

  @override
  State<AjustarPerdaPaleteScreen> createState() =>
      _AjustarPerdaPaleteScreenState();
}

class _AjustarPerdaPaleteScreenState extends State<AjustarPerdaPaleteScreen> {
  late TextEditingController quantidadePerdidaController;
  final TextEditingController motivoController = TextEditingController();

  final OPService opService = OPService();

  @override
  void initState() {
    super.initState();
    quantidadePerdidaController = TextEditingController(
      text: widget.palete.quantidadePerdida,
    );
  }

  void salvarAjuste() async {
  final quantidadePerdida = quantidadePerdidaController.text.trim();
  final motivo = motivoController.text.trim();

  try {
    await opService.ajustarPerdaPalete(
      op: widget.op,
      palete: widget.palete,
      quantidadePerdida: quantidadePerdida,
      motivo: motivo,
      usuario: widget.usuario,
    );

    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

  Widget info(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(texto),
      ),
    );
  }

  @override
  void dispose() {
    quantidadePerdidaController.dispose();
    motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palete = widget.palete;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustar Perda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            info('Palete: ${palete.numero}'),
            info('Quantidade original: ${palete.quantidadeOriginal}'),
            info('Saldo atual: ${palete.saldoAtual}'),
            const SizedBox(height: 8),
            TextField(
              controller: quantidadePerdidaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade Perdida',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo do ajuste',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvarAjuste,
                child: const Text('Salvar Ajuste'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}