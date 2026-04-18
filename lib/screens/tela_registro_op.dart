import 'package:flutter/material.dart';
import '../models/op.dart';
import '../models/palete.dart';
import '../services/op_service.dart';

class TelaRegistroOP extends StatefulWidget {
  const TelaRegistroOP({super.key});

  @override
  State<TelaRegistroOP> createState() => _TelaRegistroOPState();
}

class _TelaRegistroOPState extends State<TelaRegistroOP> {
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController medidaController = TextEditingController();
  final TextEditingController ordemController = TextEditingController();
  final TextEditingController ftController = TextEditingController();
  final TextEditingController qpController = TextEditingController();

  final OPService opService = OPService();

  List<Palete> paletes = [];

  void adicionarPalete() {
    setState(() {
      paletes.add(Palete());
    });
  }

  Widget listaPaletes() {
    return Column(
      children: paletes.asMap().entries.map((entry) {
        final int index = entry.key;
        final Palete p = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Palete ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Número do palete',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => p.numero = value,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => p.quantidade = value,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void salvarOP() {
    final String cliente = clienteController.text.trim();
    final String medida = medidaController.text.trim();
    final String ordem = ordemController.text.trim();
    final String ft = ftController.text.trim();
    final String qp = qpController.text.trim();

    if (cliente.isEmpty ||
        medida.isEmpty ||
        ordem.isEmpty ||
        ft.isEmpty ||
        qp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos da OP')),
      );
      return;
    }

    final List<Palete> paletesSalvos = paletes
        .where((p) => p.numero.trim().isNotEmpty || p.quantidade.trim().isNotEmpty)
        .map(
          (p) => Palete(
            numero: p.numero.trim(),
            quantidade: p.quantidade.trim(),
          ),
        )
        .toList();

    final op = OP(
      cliente: cliente,
      medida: medida,
      ordem: ordem,
      ft: ft,
      qp: qp,
      paletes: paletesSalvos,
    );

    setState(() {
      opService.salvarOP(op);
      paletes = [];
    });

    clienteController.clear();
    medidaController.clear();
    ordemController.clear();
    ftController.clear();
    qpController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OP salva com sucesso!')),
    );
  }

  Widget campo(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
    final ops = opService.listarOPs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de OP'),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvarOP,
                child: const Text('Salvar OP'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: adicionarPalete,
                child: const Text('Adicionar Palete'),
              ),
            ),
            const SizedBox(height: 10),
            listaPaletes(),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'OPs Salvas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ops.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Nenhuma OP salva ainda.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ops.length,
                    itemBuilder: (context, index) {
                      final op = ops[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cliente: ${op.cliente}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Medida: ${op.medida}'),
                              Text('Ordem: ${op.ordem}'),
                              Text('FT: ${op.ft}'),
                              Text('QP: ${op.qp}'),
                              const SizedBox(height: 8),
                              const Text(
                                'Paletes:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (op.paletes.isEmpty)
                                const Text('Nenhum palete informado')
                              else
                                ...op.paletes.map(
                                  (p) => Text(
                                    'Número: ${p.numero} | Quantidade: ${p.quantidade}',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}