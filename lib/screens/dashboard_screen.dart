import 'package:flutter/material.dart';
import '../enums/perfil_usuario.dart';
import '../enums/status_op.dart';
import '../models/op.dart';
import '../models/usuario.dart';
import '../services/op_service.dart';
import 'cadastro_op_screen.dart';
import 'detalhe_op_screen.dart';
import '../enums/tipo_op.dart';

enum TipoFiltroBusca {
  todos,
  ordem,
  cliente,
  ft,
  largura,
  comprimento,
  qp,
}

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
  final TextEditingController buscaController = TextEditingController();

  bool carregando = true;
  TipoOP? tipoFiltroOPSelecionado;
  late TabController _tabController;
  String filtroBusca = '';
  TipoFiltroBusca tipoFiltroSelecionado = TipoFiltroBusca.todos;

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
    buscaController.dispose();
    super.dispose();
  }

  String textoTipoOP(TipoOP tipo) {
    switch (tipo) {
      case TipoOP.onduladeira:
        return 'Onduladeira';
      case TipoOP.conversao:
        return 'Conversão';
    }
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

  String textoTipoFiltro(TipoFiltroBusca tipo) {
    switch (tipo) {
      case TipoFiltroBusca.todos:
        return 'Todos';
      case TipoFiltroBusca.ordem:
        return 'Ordem';
      case TipoFiltroBusca.cliente:
        return 'Cliente';
      case TipoFiltroBusca.ft:
        return 'FT';
      case TipoFiltroBusca.largura:
        return 'Largura';
      case TipoFiltroBusca.comprimento:
        return 'Comprimento';
      case TipoFiltroBusca.qp:
        return 'QP';
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

  bool correspondeBusca(OP op) {
    if (filtroBusca.trim().isEmpty) return true;

    final busca = filtroBusca.toLowerCase();

    switch (tipoFiltroSelecionado) {
      case TipoFiltroBusca.todos:
        return op.ordem.toLowerCase().contains(busca) ||
            op.cliente.toLowerCase().contains(busca) ||
            op.ft.toLowerCase().contains(busca) ||
            op.largura.toLowerCase().contains(busca) ||
            op.comprimento.toLowerCase().contains(busca) ||
            op.qp.toLowerCase().contains(busca);

      case TipoFiltroBusca.ordem:
        return op.ordem.toLowerCase().contains(busca);

      case TipoFiltroBusca.cliente:
        return op.cliente.toLowerCase().contains(busca);

      case TipoFiltroBusca.ft:
        return op.ft.toLowerCase().contains(busca);

      case TipoFiltroBusca.largura:
        return op.largura.toLowerCase().contains(busca);

      case TipoFiltroBusca.comprimento:
        return op.comprimento.toLowerCase().contains(busca);

      case TipoFiltroBusca.qp:
        return op.qp.toLowerCase().contains(busca);
    }
  }

  List<OP> filtrarOPsPorStatus(StatusOP status) {
  return opService
      .listarOPs()
      .where(
        (op) =>
            op.status == status &&
            correspondeBusca(op) &&
            (tipoFiltroOPSelecionado == null ||
                op.tipo == tipoFiltroOPSelecionado),
      )
      .toList();
  }

  Widget construirListaOPs(List<OP> ops) {
    if (ops.isEmpty) {
      return const Center(
        child: Text('Nenhuma OP encontrada nesta categoria.'),
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
              'Tipo: ${textoTipoOP(op.tipo)}\n'
              'Cliente: ${op.cliente}\n'
              'Medida: ${op.largura} x ${op.comprimento}\n'
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: DropdownButtonFormField<TipoOP?>(
                    value: tipoFiltroOPSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de OP',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<TipoOP?>(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...TipoOP.values.map(
                        (tipo) => DropdownMenuItem<TipoOP?>(
                          value: tipo,
                          child: Text(textoTipoOP(tipo)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoFiltroOPSelecionado = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: DropdownButtonFormField<TipoFiltroBusca>(
                    value: tipoFiltroSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por',
                      border: OutlineInputBorder(),
                    ),
                    items: TipoFiltroBusca.values.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(textoTipoFiltro(tipo)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          tipoFiltroSelecionado = value;
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: TextField(
                    controller: buscaController,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: filtroBusca.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                buscaController.clear();
                                setState(() {
                                  filtroBusca = '';
                                });
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filtroBusca = value.trim();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      construirListaOPs(emAndamento),
                      construirListaOPs(reabertas),
                      construirListaOPs(finalizadas),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton:
          widget.usuario.perfil == PerfilUsuario.apontamentoOnduladeira || 
          widget.usuario.perfil == PerfilUsuario.apontamentoConversao
              ? FloatingActionButton(
                  onPressed: abrirCadastroOP,
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}