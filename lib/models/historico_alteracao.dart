class HistoricoAlteracao {
  final String tipo;
  final String acao;
  final String usuario;
  final String motivo;
  final DateTime dataHora;

  HistoricoAlteracao({
    required this.tipo,
    required this.acao,
    required this.usuario,
    required this.motivo,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'acao': acao,
      'usuario': usuario,
      'motivo': motivo,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory HistoricoAlteracao.fromMap(Map<String, dynamic> map) {
    return HistoricoAlteracao(
      tipo: map['tipo'] ?? '',
      acao: map['acao'] ?? '',
      usuario: map['usuario'] ?? '',
      motivo: map['motivo'] ?? '',
      dataHora: DateTime.tryParse(map['dataHora'] ?? '') ?? DateTime.now(),
    );
  }
}