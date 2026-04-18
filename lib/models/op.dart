import '../enums/status_op.dart';
import 'historico_alteracao.dart';
import 'palete.dart';
import 'usuario.dart';

class OP {
  final String cliente;
  final String medida;
  final String ordem;
  final String ft;
  final String qp;
  StatusOP status;
  final Usuario criadaPor;
  final DateTime dataCriacao;
  final List<Palete> paletes;
  final List<HistoricoAlteracao> historico;
  String ultimoMotivoReabertura;
  DateTime? dataUltimaReabertura;

  OP({
    required this.cliente,
    required this.medida,
    required this.ordem,
    required this.ft,
    required this.qp,
    required this.status,
    required this.criadaPor,
    required this.dataCriacao,
    required this.paletes,
    required this.historico,
    this.ultimoMotivoReabertura = '',
    this.dataUltimaReabertura,
  });

  Map<String, dynamic> toMap() {
    return {
      'cliente': cliente,
      'medida': medida,
      'ordem': ordem,
      'ft': ft,
      'qp': qp,
      'status': status.name,
      'criadaPor': criadaPor.toMap(),
      'dataCriacao': dataCriacao.toIso8601String(),
      'paletes': paletes.map((e) => e.toMap()).toList(),
      'historico': historico.map((e) => e.toMap()).toList(),
      'ultimoMotivoReabertura': ultimoMotivoReabertura,
      'dataUltimaReabertura': dataUltimaReabertura?.toIso8601String(),
    };
  }

  factory OP.fromMap(Map<String, dynamic> map) {
    return OP(
      cliente: map['cliente'] ?? '',
      medida: map['medida'] ?? '',
      ordem: map['ordem'] ?? '',
      ft: map['ft'] ?? '',
      qp: map['qp'] ?? '',
      status: StatusOP.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusOP.emAndamento,
      ),
      criadaPor: Usuario.fromMap(
        Map<String, dynamic>.from(map['criadaPor'] ?? {}),
      ),
      dataCriacao:
          DateTime.tryParse(map['dataCriacao'] ?? '') ?? DateTime.now(),
      paletes: (map['paletes'] as List<dynamic>? ?? [])
          .map((e) => Palete.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      historico: (map['historico'] as List<dynamic>? ?? [])
          .map((e) => HistoricoAlteracao.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      ultimoMotivoReabertura: map['ultimoMotivoReabertura'] ?? '',
      dataUltimaReabertura: map['dataUltimaReabertura'] != null
          ? DateTime.tryParse(map['dataUltimaReabertura'])
          : null,
    );
  }
}