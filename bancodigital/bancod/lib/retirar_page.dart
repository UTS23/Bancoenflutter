import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetirarPage extends StatefulWidget {
  @override
  _RetirarPageState createState() => _RetirarPageState();
}

class _RetirarPageState extends State<RetirarPage> {
  final TextEditingController _montoController = TextEditingController();
  bool isLoading = false;
  String? codigoRetiro;

  Future<void> _generarCodigoRetiro() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Usuario no encontrado.")),
      );
      setState(() => isLoading = false);
      return;
    }

    double monto = double.tryParse(_montoController.text) ?? 0;
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ingrese un monto válido.")),
      );
      setState(() => isLoading = false);
      return;
    }

    var userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario no encontrado en la base de datos.")),
      );
      setState(() => isLoading = false);
      return;
    }

    double saldoActual = (userDoc['saldo'] ?? 0).toDouble();
    if (saldoActual < monto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saldo insuficiente.")),
      );
      setState(() => isLoading = false);
      return;
    }

    // Generar código de 6 dígitos
    String codigo = (Random().nextInt(900000) + 100000).toString();

    await FirebaseFirestore.instance.collection('usuarios').doc(userId).update({
      'codigo_retiro': codigo,
      'codigo_expira':
          DateTime.now().add(Duration(minutes: 30)).millisecondsSinceEpoch,
      'saldo': saldoActual - monto, // Descontar saldo
    });

    setState(() {
      codigoRetiro = codigo;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Código generado: $codigo")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Retirar')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ingrese el monto a retirar",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _generarCodigoRetiro,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Generar Código de Retiro"),
            ),
            if (codigoRetiro != null) ...[
              SizedBox(height: 20),
              Text(
                "Código de retiro: $codigoRetiro",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 10),
              Text(
                "Este código expira en 30 minutos.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
            ],
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Volver"),
            ),
          ],
        ),
      ),
    );
  }
}
