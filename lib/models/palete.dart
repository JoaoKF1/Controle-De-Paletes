import '../enums/status_palete.dart';

class Palete {
  String numero;
  String quantidadeOriginal;
  String quantidadePerdida;
  bool quebra;
  StatusPalete status;
  String ultimoMotivoAjuste;
  DateTime? dataUltimoAjuste;

  Palete({
    required this.numero,
    required this.quantidadeOriginal,
    this.quantidadePerdida = '0',
    this.quebra = false,
    required this.status,
    this.ultimoMotivoAjuste = '',
    this.dataUltimoAjuste,
  });

  int get quantidadeOriginalInt => int.tryParse(quantidadeOriginal) ?? 0;

  int get quantidadePerdidaInt => int.tryParse(quantidadePerdida) ?? 0;

  int get saldoAtual {
    final saldo = quantidadeOriginalInt - quantidadePerdidaInt;
    return saldo < 0 ? 0 : saldo;
  }

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'quantidadeOriginal': quantidadeOriginal,
      'quantidadePerdida': quantidadePerdida,
      'quebra': quebra,
      'status': status.name,
      'ultimoMotivoAjuste': ultimoMotivoAjuste,
      'dataUltimoAjuste': dataUltimoAjuste?.toIso8601String(),
    };
  }

  factory Palete.fromMap(Map<String, dynamic> map) {
    return Palete(
      numero: map['numero'] ?? '',
      quantidadeOriginal: map['quantidadeOriginal'] ?? '0',
      quantidadePerdida: map['quantidadePerdida'] ?? '0',
      quebra: map['quebra'] ?? false,
      status: StatusPalete.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusPalete.completo,
      ),
      ultimoMotivoAjuste: map['ultimoMotivoAjuste'] ?? '',
      dataUltimoAjuste: map['dataUltimoAjuste'] != null
          ? DateTime.tryParse(map['dataUltimoAjuste'])
          : null,
    );
  }
}