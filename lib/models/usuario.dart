import '../enums/perfil_usuario.dart';

class Usuario {
  final String nome;
  final String login;
  final PerfilUsuario perfil;

  Usuario({
    required this.nome,
    required this.login,
    required this.perfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'login': login,
      'perfil': perfil.name,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nome: map['nome'] ?? '',
      login: map['login'] ?? '',
      perfil: PerfilUsuario.values.firstWhere(
        (e) => e.name == map['perfil'],
        orElse: () => PerfilUsuario.operador,
      ),
    );
  }
}