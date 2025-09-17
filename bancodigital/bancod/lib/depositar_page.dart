import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepositarPage extends StatefulWidget {
  @override
  _DepositarPageState createState() => _DepositarPageState();
}

class _DepositarPageState extends State<DepositarPage> {
  final TextEditingController _montoController = TextEditingController();
  bool isLoading = false;
  String? codigoPuntoRed;

  Future<void> _procesarDeposito(String metodo) async {
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

    if (metodo == "Punto Red") {
      // Generar código de 6 dígitos para Punto Red
      String codigo = (Random().nextInt(900000) + 100000).toString();

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({
        'codigo_punto_red': codigo,
        'codigo_expira':
            DateTime.now().add(Duration(minutes: 30)).millisecondsSinceEpoch,
      });

      setState(() {
        codigoPuntoRed = codigo;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Código generado: $codigo")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Redirigiendo a PSE...")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Depositar')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ingrese el monto a depositar",
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

            // Botón PSE
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _procesarDeposito("PSE"),
              icon: Icon(Icons.account_balance, size: 24),
              label: Text("Depositar vía PSE"),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15)),
            ),
            SizedBox(height: 10),

            // Botón Punto Red
            ElevatedButton.icon(
              onPressed:
                  isLoading ? null : () => _procesarDeposito("Punto Red"),
              icon: Icon(Icons.store_mall_directory, size: 24),
              label: Text("Depositar en Punto Red"),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15)),
            ),

            if (codigoPuntoRed != null) ...[
              SizedBox(height: 20),
              Text(
                "Código Punto Red: $codigoPuntoRed",
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
