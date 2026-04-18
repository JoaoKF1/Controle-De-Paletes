import 'package:flutter/material.dart';
import 'enums/perfil_usuario.dart';
import 'models/usuario.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioLogado = Usuario(
      nome: 'João',
      login: 'joao',
      perfil: PerfilUsuario.apontamento,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de OP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: DashboardScreen(usuario: usuarioLogado),
    );
  }
}