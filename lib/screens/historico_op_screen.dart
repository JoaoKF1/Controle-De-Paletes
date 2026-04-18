import 'package:flutter/material.dart';
import '../models/op.dart';

class HistoricoOPScreen extends StatelessWidget {
  final OP op;

  const HistoricoOPScreen({
    super.key,
    required this.op,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico OP ${op.ordem}'),
      ),
      body: op.historico.isEmpty
          ? const Center(
              child: Text('Nenhum histórico registrado.'),
            )
          : ListView.builder(
              itemCount: op.historico.length,
              itemBuilder: (context, index) {
                final item = op.historico[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item.acao),
                    subtitle: Text(
                      'Tipo: ${item.tipo}\n'
                      'Usuário: ${item.usuario}\n'
                      'Motivo: ${item.motivo}\n'
                      'Data/Hora: ${item.dataHora}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}