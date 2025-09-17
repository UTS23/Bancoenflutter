import 'package:flutter/material.dart';

class RegisterStep3 extends StatefulWidget {
  final Function(String, String) onFinish;

  RegisterStep3({required this.onFinish, required void Function() onBack});

  @override
  _RegisterStep3State createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPasswordVisible = false;

  void register() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String email = emailController.text.trim();
    String password = passwordController.text.trim(); // ✅ No se encripta

    print("🔵 Registro - Contraseña ingresada sin encriptar: $password");

    Future.delayed(Duration(seconds: 2), () {
      setState(() => isLoading = false);
      widget.onFinish(email, password); // ✅ Se envía tal cual
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text("Crear Cuenta",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            // Campo de Correo
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                String trimmedValue = value!.trim();
                if (trimmedValue.isEmpty)
                  return 'Ingrese su correo electrónico';
                if (trimmedValue.contains(' '))
                  return 'El correo no debe contener espacios';
                if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(trimmedValue)) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            SizedBox(height: 12),

            // Campo de Contraseña (Solo Números)
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña (solo números)',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(isPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() => isPasswordVisible = !isPasswordVisible);
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              obscureText: !isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Ingrese una contraseña';
                if (value.contains(' '))
                  return 'La contraseña no debe contener espacios';
                if (!RegExp(r'^[0-9]+$').hasMatch(value))
                  return 'Solo se permiten números';
                if (value.length < 6) return 'Debe tener al menos 6 dígitos';
                return null;
              },
            ),
            SizedBox(height: 20),

            // Botón de Registro
            ElevatedButton(
              onPressed: isLoading ? null : register,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blueAccent,
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Finalizar Registro"),
            ),
          ],
        ),
      ),
    );
  }
}
