import 'package:flutter/material.dart';
import '../models/op.dart';
import '../models/palete.dart';
import '../models/usuario.dart';
import '../services/op_service.dart';

class EditarPaleteScreen extends StatefulWidget {
  final OP op;
  final Palete palete;
  final Usuario usuario;

  const EditarPaleteScreen({
    super.key,
    required this.op,
    required this.palete,
    required this.usuario,
  });

  @override
  State<EditarPaleteScreen> createState() => _EditarPaleteScreenState();
}

class _EditarPaleteScreenState extends State<EditarPaleteScreen> {
  late TextEditingController numeroController;
  late TextEditingController quantidadeOriginalController;

  final OPService opService = OPService();

  late bool isQuebra;

  @override
  void initState() {
    super.initState();
    numeroController = TextEditingController(text: widget.palete.numero);
    quantidadeOriginalController = TextEditingController(
      text: widget.palete.quantidadeOriginal,
    );
    isQuebra = widget.palete.quebra;
  }

  void salvarEdicao() async {
  final numero = numeroController.text.trim();
  final quantidadeOriginal = quantidadeOriginalController.text.trim();

  if (numero.isEmpty || quantidadeOriginal.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preencha número e quantidade original'),
      ),
    );
    return;
  }

  try {
    await opService.editarPalete(
      op: widget.op,
      palete: widget.palete,
      numero: numero,
      quantidadeOriginal: quantidadeOriginal,
      quebra: isQuebra,
      usuario: widget.usuario,
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
    numeroController.dispose();
    quantidadeOriginalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Palete'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            campo('Número do Palete', numeroController),
            campo(
              'Quantidade Original',
              quantidadeOriginalController,
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Palete de Quebra'),
              value: isQuebra,
              onChanged: (value) {
                setState(() {
                  isQuebra = value;
                });
              },
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvarEdicao,
                child: const Text('Salvar Alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}