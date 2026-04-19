import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPaleteScreen extends StatefulWidget {
  const ScannerPaleteScreen({super.key});

  @override
  State<ScannerPaleteScreen> createState() => _ScannerPaleteScreenState();
}

class _ScannerPaleteScreenState extends State<ScannerPaleteScreen> {
  final MobileScannerController controller = MobileScannerController();

  bool _jaLeu = false;

  String extrairNumeroPalete(String codigo) {
    final codigoLimpo = codigo.trim();

    if (codigoLimpo.length < 2) {
      throw Exception('Código de barras inválido.');
    }

    final ultimos3 = codigoLimpo.substring(codigoLimpo.length - 2);
    final numeroInt = int.tryParse(ultimos3);

    if (numeroInt == null || numeroInt <= 0) {
      throw Exception('Não foi possível identificar o número do palete.');
    }

    return numeroInt.toString().padLeft(2, '0');
  }

  void processarCodigo(String codigo) {
    if (_jaLeu) return;

    try {
      final numeroPalete = extrairNumeroPalete(codigo);
      _jaLeu = true;
      Navigator.pop(context, numeroPalete);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler Código de Barras'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;

              if (barcodes.isEmpty) return;

              final rawValue = barcodes.first.rawValue;
              if (rawValue == null || rawValue.isEmpty) return;

              processarCodigo(rawValue);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Aponte a câmera para o código do palete',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}