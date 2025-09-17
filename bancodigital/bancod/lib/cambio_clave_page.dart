import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CambioClavePage extends StatefulWidget {
  @override
  _CambioClavePageState createState() => _CambioClavePageState();
}

class _CambioClavePageState extends State<CambioClavePage> {
  final _formKey = GlobalKey<FormState>();
  final _claveActualController = TextEditingController();
  final _nuevaClaveController = TextEditingController();
  final _confirmarClaveController = TextEditingController();

  bool isLoading = false;
  bool mostrarClaveActual = false;
  bool mostrarClaveNueva = false;
  bool mostrarConfirmacion = false;
  int intentosFallidos = 0;

  Future<void> _cambiarClave() async {
    if (!_formKey.currentState!.validate()) return;

    final claveActual = _claveActualController.text.trim();
    final nuevaClave = _nuevaClaveController.text.trim();
    final confirmarClave = _confirmarClaveController.text.trim();

    if (nuevaClave != confirmarClave) {
      _mostrarMensaje("Las claves no coinciden.");
      return;
    }

    if (intentosFallidos >= 3) {
      _mostrarMensaje("Demasiados intentos fallidos. Intenta más tarde.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _mostrarMensaje("Usuario no encontrado.");
        return;
      }

      final userRef =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        _mostrarMensaje("No se encontró el usuario.");
        return;
      }

      final salt = userDoc.get('salt');
      final storedPassword = userDoc.get('password');
      final claveActualHash = _encriptarClave(claveActual, salt);

      if (claveActualHash != storedPassword) {
        intentosFallidos++;
        _mostrarMensaje("Clave incorrecta. Intento $intentosFallidos/3");
        await Future.delayed(
            Duration(milliseconds: Random().nextInt(400) + 600));
        return;
      }

      final nuevoSalt = _generarSalt();
      final nuevaClaveHash = _encriptarClave(nuevaClave, nuevoSalt);

      await userRef.update({'password': nuevaClaveHash, 'salt': nuevoSalt});

      _mostrarMensaje("✅ Clave actualizada con éxito", success: true);
      await Future.delayed(Duration(milliseconds: 800));
      Navigator.pop(context);
    } catch (e) {
      print("🔥 ERROR: $e");
      _mostrarMensaje("Error al actualizar la clave.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _encriptarClave(String clave, String salt) {
    return sha256.convert(utf8.encode(clave + salt)).toString();
  }

  String _generarSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  void _mostrarMensaje(String mensaje, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error,
                color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool mostrar,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !mostrar,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(mostrar ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar Clave"),
        backgroundColor: Colors.blueAccent.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                label: "Clave Actual",
                controller: _claveActualController,
                mostrar: mostrarClaveActual,
                onToggle: () =>
                    setState(() => mostrarClaveActual = !mostrarClaveActual),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Campo obligatorio";
                  if (!RegExp(r'^\d{6}$').hasMatch(value))
                    return "Debe tener 6 dígitos numéricos";
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildPasswordField(
                label: "Nueva Clave",
                controller: _nuevaClaveController,
                mostrar: mostrarClaveNueva,
                onToggle: () =>
                    setState(() => mostrarClaveNueva = !mostrarClaveNueva),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Campo obligatorio";
                  if (!RegExp(r'^\d{6}$').hasMatch(value))
                    return "Debe tener 6 dígitos numéricos";
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildPasswordField(
                label: "Confirmar Clave",
                controller: _confirmarClaveController,
                mostrar: mostrarConfirmacion,
                onToggle: () =>
                    setState(() => mostrarConfirmacion = !mostrarConfirmacion),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Campo obligatorio";
                  if (!RegExp(r'^\d{6}$').hasMatch(value))
                    return "Debe tener 6 dígitos numéricos";
                  return null;
                },
              ),
              SizedBox(height: 28),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.lock_reset),
                          label: Text("Actualizar Clave"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                          onPressed: _cambiarClave,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
