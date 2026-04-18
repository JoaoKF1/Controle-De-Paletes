import 'package:flutter/material.dart';
import '../enums/perfil_usuario.dart';
import '../enums/status_op.dart';
import '../models/op.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final OPService opService = OPService();
  bool carregando = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    carregarDados();
  }

  Future<void> carregarDados() async {
    await opService.carregarOPs();
    setState(() {
      carregando = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> abrirDetalheOP(OP op) async {
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

  List<OP> filtrarOPsPorStatus(StatusOP status) {
    return opService.listarOPs().where((op) => op.status == status).toList();
  }

  Widget construirListaOPs(List<OP> ops) {
    if (ops.isEmpty) {
      return const Center(
        child: Text('Nenhuma OP nesta categoria.'),
      );
    }

    return ListView.builder(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final emAndamento = filtrarOPsPorStatus(StatusOP.emAndamento);
    final reabertas = filtrarOPsPorStatus(StatusOP.reaberta);
    final finalizadas = filtrarOPsPorStatus(StatusOP.finalizada);

    return Scaffold(
      appBar: AppBar(
        title: Text('OPs - ${widget.usuario.nome}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Em andamento (${emAndamento.length})'),
            Tab(text: 'Reabertas (${reabertas.length})'),
            Tab(text: 'Finalizadas (${finalizadas.length})'),
          ],
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                construirListaOPs(emAndamento),
                construirListaOPs(reabertas),
                construirListaOPs(finalizadas),
              ],
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