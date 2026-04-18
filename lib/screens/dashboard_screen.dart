import 'package:flutter/material.dart';
import '../enums/perfil_usuario.dart';
import '../enums/status_op.dart';
import '../models/usuario.dart';
import '../services/op_service.dart';
import 'cadastro_op_screen.dart';
import 'detalhe_op_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;

  const DashboardScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final OPService opService = OPService();
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    await opService.carregarOPs();
    setState(() {
      carregando = false;
    });
  }

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

  Future<void> abrirCadastroOP() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroOPScreen(usuario: widget.usuario),
      ),
    );

    if (resultado == true) {
      setState(() {});
    }
  }

  Future<void> abrirDetalheOP(op) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalheOPScreen(
          op: op,
          usuario: widget.usuario,
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ops = opService.listarOPs();

    return Scaffold(
      appBar: AppBar(
        title: Text('OPs - ${widget.usuario.nome}'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ops.isEmpty
              ? const Center(
                  child: Text('Nenhuma OP cadastrada ainda.'),
                )
              : ListView.builder(
                  itemCount: ops.length,
                  itemBuilder: (context, index) {
                    final op = ops[index];
                    final totalChapas = opService.calcularTotalChapas(op);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () => abrirDetalheOP(op),
                        title: Text('Ordem: ${op.ordem}'),
                        subtitle: Text(
                          'Cliente: ${op.cliente}\n'
                          'FT: ${op.ft}\n'
                          'QP: ${op.qp}\n'
                          'Status: ${textoStatus(op.status)}\n'
                          'Paletes: ${op.paletes.length}\n'
                          'Total de chapas: $totalChapas',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                ),
      floatingActionButton:
          widget.usuario.perfil == PerfilUsuario.apontamento
              ? FloatingActionButton(
                  onPressed: abrirCadastroOP,
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}