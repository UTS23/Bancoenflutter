import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bancod/usuario_service.dart';
import 'factura_page.dart';

class EnviarDineroPage extends StatefulWidget {
  @override
  _EnviarDineroPageState createState() => _EnviarDineroPageState();
}

class _EnviarDineroPageState extends State<EnviarDineroPage> {
  final TextEditingController _cuentaController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();
  final UsuarioService _usuarioService = UsuarioService();

  bool isButtonEnabled = false;
  String destinatario = "";
  String errorCuenta = "";
  bool buscandoCuenta = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  void _onCuentaChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 800), _verificarCuenta);
  }

  Future<void> _verificarCuenta() async {
    String cuentaDestino = _cuentaController.text.trim();

    if (cuentaDestino.length < 10) {
      setState(() {
        destinatario = "";
        errorCuenta = "Debe ingresar 10 números.";
        buscandoCuenta = false;
      });
      return;
    }

    setState(() {
      buscandoCuenta = true;
      destinatario = "";
      errorCuenta = "";
    });

    try {
      var usuario = await _usuarioService.buscarCuenta(cuentaDestino);

      setState(() {
        buscandoCuenta = false;
        if (usuario != null) {
          destinatario = "${usuario['nombre']} ${usuario['apellido']}";
          errorCuenta = "";
        } else {
          destinatario = "";
          errorCuenta = "Número de cuenta no encontrado";
        }
        _validarCampos();
      });
    } catch (e) {
      setState(() {
        buscandoCuenta = false;
        errorCuenta = "Error al verificar la cuenta";
      });
    }
  }

  void _validarCampos() {
    setState(() {
      double? monto = double.tryParse(_montoController.text);
      bool montoValido = monto != null && monto > 0;

      isButtonEnabled = _cuentaController.text.length == 10 &&
          montoValido &&
          destinatario.isNotEmpty &&
          _conceptoController.text.isNotEmpty;
    });
  }

  Future<void> _enviarDinero() async {
    try {
      final double monto = double.parse(_montoController.text);
      final String cuentaDestino = _cuentaController.text;
      final String concepto = _conceptoController.text;

      bool resultado = await _usuarioService.enviarDinero(cuentaDestino, monto);

      if (resultado) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FacturaPage(
              cuentaDestino: cuentaDestino,
              destinatario: destinatario,
              monto: monto,
              concepto: concepto,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error en la transferencia"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Ocurrió un error inesperado."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enviar Dinero"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cuentaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Número de cuenta destino",
                border: OutlineInputBorder(),
                errorText: errorCuenta.isNotEmpty ? errorCuenta : null,
              ),
              onChanged: (_) => _onCuentaChanged(),
            ),
            if (destinatario.isNotEmpty) Text("Destinatario: $destinatario"),
            SizedBox(height: 15),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto a enviar",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _validarCampos(),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _conceptoController,
              decoration: InputDecoration(
                labelText: "Concepto",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _validarCampos(),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: isButtonEnabled ? _enviarDinero : null,
              child: Text("Confirmar Envío"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cuentaController.dispose();
    _montoController.dispose();
    _conceptoController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
