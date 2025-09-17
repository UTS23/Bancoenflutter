import 'package:flutter/material.dart';
import 'login_password.dart';

class LoginEmailPage extends StatefulWidget {
  @override
  _LoginEmailPageState createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _validateEmail() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Oculta el teclado
      setState(() => _isLoading = true);

      await Future.delayed(Duration(seconds: 1)); // Simula una verificación

      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPasswordPage(
              email: _emailController.text.trim().toLowerCase()),
        ),
      );
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Por favor, ingresa tu correo electrónico";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return "El formato del correo no es válido";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Hero(
                    tag: 'logo',
                    child: Icon(Icons.account_balance,
                        size: 90, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Bienvenido a Banco Digital",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ingresa tu correo electrónico para continuar",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Correo electrónico",
                            hintText: "ejemplo@correo.com",
                            prefixIcon:
                                Icon(Icons.email_outlined, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                        ),
                        SizedBox(height: 24),
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton.icon(
                                onPressed: _validateEmail,
                                icon: Icon(Icons.arrow_forward_ios),
                                label: Text("Siguiente"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue.shade900,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  textStyle: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                  shadowColor: Colors.black54,
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("¿Necesitas ayuda?"),
                          content: Text(
                              "Escríbenos al WhatsApp 3165125962 si tienes problemas para ingresar."),
                          actions: [
                            TextButton(
                              child: Text("Cerrar"),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      );
                    },
                    child: Text(
                      "¿Necesitas ayuda?",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
