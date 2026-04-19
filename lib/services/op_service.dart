import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../enums/perfil_usuario.dart';
import '../enums/status_op.dart';
import '../enums/status_palete.dart';
import '../enums/tipo_onda.dart';
import '../models/op.dart';
import '../models/palete.dart';
import '../models/usuario.dart';
import 'historico_service.dart';

class OPService {
  static final OPService _instance = OPService._internal();

  factory OPService() {
    return _instance;
  }

  OPService._internal();

  static const String _storageKey = 'ops_storage';

  final List<OP> _ops = [];
  final HistoricoService historicoService = HistoricoService();

  bool _carregado = false;

  List<OP> listarOPs() {
    return _ops;
  }

  Future<void> carregarOPs() async {
    if (_carregado) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _ops
        ..clear()
        ..addAll(
          decoded.map((e) => OP.fromMap(Map<String, dynamic>.from(e))),
        );
    }

    _carregado = true;
  }

  Future<void> salvarOPsNoDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_ops.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  String textoOnda(TipoOnda onda) {
    switch (onda) {
      case TipoOnda.b:
        return 'B';
      case TipoOnda.c:
        return 'C';
      case TipoOnda.dc:
        return 'DC';
      case TipoOnda.db:
        return 'DB';
    }
  }

  int quantidadePadraoPorOnda(TipoOnda onda) {
    switch (onda) {
      case TipoOnda.b:
        return 385;
      case TipoOnda.c:
        return 286;
      case TipoOnda.dc:
        return 192;
      case TipoOnda.db:
        return 207;
    }
  }

  Future<void> criarOP({
    required String cliente,
    required String largura,
    required String comprimento,
    required String ordem,
    required String ft,
    required String qp,
    required TipoOnda onda,
    required Usuario usuario,
  }) async {
    if (usuario.perfil != PerfilUsuario.apontamento) {
      throw Exception('Usuário sem permissão para criar OP.');
    }

    final op = OP(
      cliente: cliente,
      largura: largura,
      comprimento: comprimento,
      ordem: ordem,
      ft: ft,
      qp: qp,
      onda: onda,
      status: StatusOP.emAndamento,
      criadaPor: usuario,
      dataCriacao: DateTime.now(),
      paletes: [],
      historico: [],
    );

    _ops.add(op);

    historicoService.registrar(
      op: op,
      tipo: 'OP',
      acao: 'Criação da OP',
      usuario: usuario,
      motivo: 'Criação inicial',
    );

    await salvarOPsNoDispositivo();
  }

  String normalizarNumeroPalete(String numero) {
    final numeroLimpo = numero.trim();

    if (numeroLimpo.isEmpty) {
      throw Exception('Número do palete é obrigatório.');
    }

    final numeroInt = int.tryParse(numeroLimpo);

    if (numeroInt == null || numeroInt <= 0) {
      throw Exception('Número do palete inválido.');
    }

    return numeroInt.toString().padLeft(3, '0');
  }

  bool existeNumeroPalete(OP op, String numeroNormalizado) {
    return op.paletes.any((p) => p.numero == numeroNormalizado);
  }

  bool existeNumeroPaleteIgnorandoAtual(
    OP op,
    String numeroNormalizado,
    Palete paleteAtual,
  ) {
    return op.paletes.any(
      (p) => p != paleteAtual && p.numero == numeroNormalizado,
    );
  }

  Future<void> adicionarPalete({
    required OP op,
    required String numero,
    required bool quebra,
    required String? quantidadeQuebra,
    required Usuario usuario,
  }) async {
    if (usuario.perfil != PerfilUsuario.apontamento) {
      throw Exception('Usuário sem permissão para registrar paletes.');
    }

    if (op.status == StatusOP.finalizada) {
      throw Exception('Não é possível adicionar paletes em uma OP finalizada.');
    }

    final numeroNormalizado = normalizarNumeroPalete(numero);

    if (existeNumeroPalete(op, numeroNormalizado)) {
      throw Exception('Já existe um palete com esse número nesta OP.');
    }

    int quantidadeOriginal;

    if (quebra) {
      final qtdQuebra = int.tryParse((quantidadeQuebra ?? '').trim()) ?? 0;
      if (qtdQuebra <= 0) {
        throw Exception('Quantidade da quebra inválida.');
      }
      quantidadeOriginal = qtdQuebra;
    } else {
      quantidadeOriginal = quantidadePadraoPorOnda(op.onda);
    }

    final palete = Palete(
      numero: numeroNormalizado,
      quantidadeOriginal: quantidadeOriginal.toString(),
      quantidadePerdida: '0',
      quebra: quebra,
      status: quebra ? StatusPalete.quebra : StatusPalete.completo,
    );

    op.paletes.add(palete);

    historicoService.registrar(
      op: op,
      tipo: 'Palete',
      acao: 'Registro do palete ${palete.numero}',
      usuario: usuario,
      motivo: quebra
          ? 'Registro de palete de quebra'
          : 'Registro de palete completo',
    );

    await salvarOPsNoDispositivo();
  }

  Future<void> editarPalete({
    required OP op,
    required Palete palete,
    required String numero,
    required String quantidadeOriginal,
    required bool quebra,
    required Usuario usuario,
  }) async {
    if (usuario.perfil != PerfilUsuario.apontamento) {
      throw Exception('Usuário sem permissão para editar paletes.');
    }

    if (op.status == StatusOP.finalizada) {
      throw Exception('Não é possível editar paletes de uma OP finalizada.');
    }

    final numeroNormalizado = normalizarNumeroPalete(numero);

    if (existeNumeroPaleteIgnorandoAtual(op, numeroNormalizado, palete)) {
      throw Exception('Já existe outro palete com esse número nesta OP.');
    }

    final qtdOriginalInt = int.tryParse(quantidadeOriginal.trim()) ?? 0;

    if (qtdOriginalInt <= 0) {
      throw Exception('Quantidade original inválida.');
    }

    final qtdPerdidaAtual = palete.quantidadePerdidaInt;

    if (qtdPerdidaAtual > qtdOriginalInt) {
      throw Exception(
        'A quantidade original não pode ser menor que a perda já registrada.',
      );
    }

    final numeroAntigo = palete.numero;

    palete.numero = numeroNormalizado;
    palete.quantidadeOriginal = qtdOriginalInt.toString();
    palete.quebra = quebra;
    palete.status = quebra ? StatusPalete.quebra : StatusPalete.completo;

    historicoService.registrar(
      op: op,
      tipo: 'Palete',
      acao: 'Edição do palete $numeroAntigo',
      usuario: usuario,
      motivo: 'Alteração manual dos dados do palete',
    );

    await salvarOPsNoDispositivo();
  }

  Future<void> ajustarPerdaPalete({
    required OP op,
    required Palete palete,
    required String quantidadePerdida,
    required String motivo,
    required Usuario usuario,
  }) async {
    if (usuario.perfil != PerfilUsuario.apontamento) {
      throw Exception('Usuário sem permissão para ajustar perdas.');
    }

    if (op.status == StatusOP.finalizada) {
      throw Exception('Não é possível ajustar perdas em uma OP finalizada.');
    }

    if (motivo.trim().isEmpty) {
      throw Exception('Informe o motivo do ajuste de perda.');
    }

    final perdaInt = int.tryParse(quantidadePerdida.trim()) ?? -1;

    if (perdaInt < 0) {
      throw Exception('Quantidade perdida inválida.');
    }

    if (perdaInt > palete.quantidadeOriginalInt) {
      throw Exception(
        'A quantidade perdida não pode ser maior que a quantidade original.',
      );
    }

    palete.quantidadePerdida = perdaInt.toString();
    palete.ultimoMotivoAjuste = motivo.trim();
    palete.dataUltimoAjuste = DateTime.now();

    historicoService.registrar(
      op: op,
      tipo: 'Palete',
      acao: 'Ajuste de perda do palete ${palete.numero}',
      usuario: usuario,
      motivo: motivo,
    );

    await salvarOPsNoDispositivo();
  }

  Future<void> finalizarOP({
    required OP op,
    required Usuario usuario,
  }) async {
    if (usuario.perfil != PerfilUsuario.apontamento) {
      throw Exception('Usuário sem permissão para finalizar OP.');
    }

    if (op.paletes.isEmpty) {
      throw Exception('Não é possível finalizar uma OP sem paletes.');
    }

    op.status = StatusOP.finalizada;

    historicoService.registrar(
      op: op,
      tipo: 'OP',
      acao: 'Finalização da OP',
      usuario: usuario,
      motivo: 'Finalização operacional',
    );

    await salvarOPsNoDispositivo();
  }

  Future<void> reabrirOP({
    required OP op,
    required String motivo,
    required Usuario usuario,
  }) async {
    if (usuario.perfil != PerfilUsuario.apontamento) {
      throw Exception('Usuário sem permissão para reabrir OP.');
    }

    if (op.status != StatusOP.finalizada) {
      throw Exception('Somente OPs finalizadas podem ser reabertas.');
    }

    if (motivo.trim().isEmpty) {
      throw Exception('Informe o motivo da reabertura.');
    }

    op.status = StatusOP.reaberta;
    op.ultimoMotivoReabertura = motivo.trim();
    op.dataUltimaReabertura = DateTime.now();

    historicoService.registrar(
      op: op,
      tipo: 'OP',
      acao: 'Reabertura da OP',
      usuario: usuario,
      motivo: motivo,
    );

    await salvarOPsNoDispositivo();
  }

  int calcularTotalChapas(OP op) {
    final qp = int.tryParse(op.qp) ?? 0;
    int total = 0;

    for (final palete in op.paletes) {
      total += palete.saldoAtual * qp;
    }

    return total;
  }
}