import 'package:bancod/register_step1.dart';
import 'package:bancod/register_step2.dart';
import 'package:bancod/register_step3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Datos del usuario
  String name = '';
  String lastName = '';
  int age = 18;
  String? docType;
  String documento = '';
  String ingresos = '';
  String egresos = '';
  String direccion = '';
  String telefono = '';
  String numeroCuenta = '';
  String email = '';
  String password = '';

  /// 🔹 Encripta la contraseña con SHA-256
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password.trim())).toString();
  }

  /// 🔹 Genera el número de cuenta eliminando el código de país y espacios
  String generarNumeroCuenta(String telefono) {
    return telefono.replaceAll(RegExp(r'^\+\d{1,3}'), '').replaceAll(' ', '');
  }

  /// 🔹 Verifica si un usuario ya existe en la base de datos
  Future<bool> isUserExists(String field, String value) async {
    var query = await _firestore
        .collection('usuarios')
        .where(field, isEqualTo: value)
        .get();
    return query.docs.isNotEmpty;
  }

  /// 🔹 Verifica que la contraseña tenga al menos 6 caracteres
  bool isPasswordSecure(String password) {
    return password.length >= 6;
  }

  /// 🔹 Registra al usuario en Firestore con seguridad
  Future<void> register() async {
    try {
      setState(() => isLoading = true);

      // Validaciones finales
      if (email.isEmpty ||
          password.isEmpty ||
          name.isEmpty ||
          lastName.isEmpty ||
          documento.isEmpty ||
          telefono.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Todos los campos son obligatorios.'),
              backgroundColor: Colors.red),
        );
        setState(() => isLoading = false);
        return;
      }

      if (!isPasswordSecure(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('La contraseña debe tener al menos 6 caracteres.'),
              backgroundColor: Colors.red),
        );
        setState(() => isLoading = false);
        return;
      }

      // 🔹 Encripta la contraseña solo aquí antes de guardarla
      String hashedPassword = hashPassword(password);

      // 🔹 Genera el número de cuenta eliminando el código de país y espacios
      numeroCuenta = generarNumeroCuenta(telefono);

      // 🔍 Verificar duplicados en Firestore
      bool emailExists = await isUserExists('email', email);
      bool phoneExists = await isUserExists('telefono', telefono);
      bool documentExists = await isUserExists('numero_documento', documento);
      bool accountExists = await isUserExists('numeroCuenta', numeroCuenta);

      if (emailExists || phoneExists || documentExists || accountExists) {
        String message = 'Ya existe un usuario con ';
        if (emailExists) message += 'ese email. ';
        if (phoneExists) message += 'ese teléfono. ';
        if (documentExists) message += 'ese número de documento. ';
        if (accountExists) message += 'ese número de cuenta.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        setState(() => isLoading = false);
        return;
      }

      // 🔹 Guardar en Firestore
      await _firestore.collection('usuarios').add({
        'nombre': name,
        'apellido': lastName,
        'email': email,
        'password': hashedPassword,
        'edad': age,
        'tipo_documento': docType,
        'numero_documento': documento,
        'ingresos': ingresos,
        'egresos': egresos,
        'direccion': direccion,
        'telefono': telefono,
        'numeroCuenta': numeroCuenta,
        'saldo': 0.0,
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Registro exitoso ✅'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al registrar: ${error.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  /// 🔹 Navegación entre pasos del formulario
  void nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                RegisterStep1(
                  onNext: (String nameValue, String lastNameValue, int ageValue,
                      String? docTypeValue, String documentoValue) {
                    setState(() {
                      name = nameValue.trim();
                      lastName = lastNameValue.trim();
                      age = ageValue;
                      docType = docTypeValue;
                      documento = documentoValue.trim();
                    });
                    nextPage();
                  },
                ),
                RegisterStep2(
                  onNext: (String ingresosValue, String egresosValue,
                      String direccionValue, String telefonoValue) {
                    setState(() {
                      ingresos = ingresosValue.trim();
                      egresos = egresosValue.trim();
                      direccion = direccionValue.trim();
                      telefono = telefonoValue.trim();
                      numeroCuenta = generarNumeroCuenta(
                          telefono); // 🔹 Genera el número de cuenta sin espacios
                    });
                    nextPage();
                  },
                  onBack: previousPage,
                ),
                RegisterStep3(
                  onFinish: (String emailValue, String passwordValue) {
                    setState(() {
                      email = emailValue.trim().toLowerCase();
                      password = passwordValue.trim();
                    });
                    register();
                  },
                  onBack: previousPage,
                ),
              ],
            ),
    );
  }
}
