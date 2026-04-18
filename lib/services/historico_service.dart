import '../models/historico_alteracao.dart';
import '../models/op.dart';
import '../models/usuario.dart';

class HistoricoService {
  static final HistoricoService _instance = HistoricoService._internal();

  factory HistoricoService() {
    return _instance;
  }

  HistoricoService._internal();

  void registrar({
    required OP op,
    required String tipo,
    required String acao,
    required Usuario usuario,
    required String motivo,
  }) {
    op.historico.add(
      HistoricoAlteracao(
        tipo: tipo,
        acao: acao,
        usuario: usuario.nome,
        motivo: motivo,
        dataHora: DateTime.now(),
      ),
    );
  }
}