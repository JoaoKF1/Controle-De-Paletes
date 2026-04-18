import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/op_service.dart';

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
  final TextEditingController medidaController = TextEditingController();
  final TextEditingController ordemController = TextEditingController();
  final TextEditingController ftController = TextEditingController();
  final TextEditingController qpController = TextEditingController();

  final OPService opService = OPService();

  void salvar() async {
    final cliente = clienteController.text.trim();
    final medida = medidaController.text.trim();
    final ordem = ordemController.text.trim();
    final ft = ftController.text.trim();
    final qp = qpController.text.trim();

    if (cliente.isEmpty ||
        medida.isEmpty ||
        ordem.isEmpty ||
        ft.isEmpty ||
        qp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      await opService.criarOP(
        cliente: cliente,
        medida: medida,
        ordem: ordem,
        ft: ft,
        qp: qp,
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
    medidaController.dispose();
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
            campo('Cliente', clienteController),
            campo('Medida', medidaController),
            campo('Ordem', ordemController),
            campo('FT', ftController),
            campo(
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