import 'package:flutter/material.dart';
import '../enums/tipo_onda.dart';
import '../models/usuario.dart';
import '../services/op_service.dart';
import '../enums/tipo_op.dart';

class CadastroOPScreen extends StatefulWidget {
  final Usuario usuario;

  const CadastroOPScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<CadastroOPScreen> createState() => _CadastroOPScreenState();
}

class _CadastroOPScreenState extends State<CadastroOPScreen> {
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController larguraController = TextEditingController();
  final TextEditingController comprimentoController = TextEditingController();
  final TextEditingController ordemController = TextEditingController();
  final TextEditingController ftController = TextEditingController();
  final TextEditingController qpController = TextEditingController();

  final OPService opService = OPService();

  TipoOnda? ondaSelecionada = TipoOnda.c;
  TipoOP tipoSelecionado = TipoOP.onduladeira;

  void salvar() async {
    final cliente = clienteController.text.trim();
    final largura = larguraController.text.trim();
    final comprimento = comprimentoController.text.trim();
    final ordem = ordemController.text.trim();
    final ft = ftController.text.trim();
    final qp = qpController.text.trim();

    if (cliente.isEmpty ||
        largura.isEmpty ||
        comprimento.isEmpty ||
        ordem.isEmpty ||
        ft.isEmpty ||
        qp.isEmpty ||
        ondaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      await opService.criarOP(
        cliente: cliente,
        largura: largura,
        comprimento: comprimento,
        ordem: ordem,
        ft: ft,
        qp: qp,
        onda: ondaSelecionada!,
        tipo: tipoSelecionado,
        usuario: widget.usuario,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OP criada com sucesso')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget campo(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget campoUnico(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
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
    clienteController.dispose();
    larguraController.dispose();
    comprimentoController.dispose();
    ordemController.dispose();
    ftController.dispose();
    qpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de OP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<TipoOP>(
                value: tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de OP',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TipoOP.onduladeira,
                    child: Text('Onduladeira'),
                  ),
                  DropdownMenuItem(
                    value: TipoOP.conversao,
                    child: Text('Conversão'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      tipoSelecionado = value;
                    });
                  }
                },
              ),
            ),
            campoUnico('Cliente', clienteController),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  campo(
                    'Largura',
                    larguraController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(width: 12),
                  campo(
                    'Comprimento',
                    comprimentoController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<TipoOnda>(
                value: ondaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Onda',
                  border: OutlineInputBorder(),
                ),
                items: TipoOnda.values.map((onda) {
                  return DropdownMenuItem(
                    value: onda,
                    child: Text(opService.textoOnda(onda)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    ondaSelecionada = value;
                  });
                },
              ),
            ),
            campoUnico('Ordem', ordemController),
            campoUnico('FT', ftController),
            campoUnico(
              'QP (Quantidade de Pilhas)',
              qpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvar,
                child: const Text('Salvar OP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}