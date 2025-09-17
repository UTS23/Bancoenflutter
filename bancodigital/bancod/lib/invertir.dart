import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InversionScreen extends StatefulWidget {
  @override
  _InversionScreenState createState() => _InversionScreenState();
}

class _InversionScreenState extends State<InversionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double saldo = 0.0;
  double montoInvertir = 0.0;
  double totalInvertido = 0.0;
  double rendimientoAcumulado = 0.0;
  String userId = "";
  List<Map<String, dynamic>> historialInversiones = [];
  DateTime? ultimaActualizacionRendimiento;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
    cargarHistorialInversiones();
    cargarUltimaActualizacionRendimiento();
  }

  Future<void> cargarUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');
    if (id != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(id).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>? ?? {};
        setState(() {
          userId = id;
          saldo = (data['saldo'] as num?)?.toDouble() ?? 0.0;
          totalInvertido = (data['totalInvertido'] as num?)?.toDouble() ?? 0.0;
        });
      }
    }
  }

  Future<void> cargarHistorialInversiones() async {
    if (userId.isNotEmpty) {
      QuerySnapshot snapshot = await _firestore
          .collection('invertir')
          .where('userId', isEqualTo: userId)
          .orderBy('fecha', descending: true)
          .get();
      setState(() {
        historialInversiones = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'monto': data['monto'] as num,
            'fecha': (data['fecha'] as Timestamp).toDate(),
          };
        }).toList();
      });
    }
  }

  Future<void> invertirSaldo(double cantidad) async {
    if (cantidad > 0 && cantidad <= saldo) {
      // Realizar la inversión
      await _firestore.collection('invertir').add({
        'userId': userId,
        'monto': cantidad,
        'fecha': Timestamp.now(),
      });

      // Actualizar el saldo del usuario en Firestore
      await _firestore.collection('usuarios').doc(userId).update({
        'saldo': FieldValue.increment(
            -cantidad), // Restar el monto invertido del saldo
        'totalInvertido':
            FieldValue.increment(cantidad), // Incrementar el total invertido
      });

      // Actualizar el estado local de la interfaz
      setState(() {
        saldo -= cantidad;
        totalInvertido += cantidad;
        historialInversiones.insert(0, {
          'monto': cantidad,
          'fecha': DateTime.now(),
        });
      });

      // Guardar la fecha de la última actualización del rendimiento
      guardarUltimaActualizacionRendimiento();
    } else {
      // Si la cantidad es inválida (mayor al saldo disponible o negativa)
      print("Cantidad no válida");
    }
  }

  Future<void> cargarUltimaActualizacionRendimiento() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fechaString = prefs.getString('ultimaActualizacionRendimiento');
    if (fechaString != null) {
      setState(() {
        ultimaActualizacionRendimiento = DateTime.parse(fechaString);
      });
      calcularRendimiento();
    }
  }

  Future<void> guardarUltimaActualizacionRendimiento() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'ultimaActualizacionRendimiento', DateTime.now().toIso8601String());
  }

  void calcularRendimiento() {
    DateTime ahora = DateTime.now();
    if (ultimaActualizacionRendimiento != null) {
      Duration duracion = ahora.difference(ultimaActualizacionRendimiento!);
      double rendimiento =
          totalInvertido * 0.02 * (duracion.inDays); // 2% diario
      setState(() {
        rendimientoAcumulado = rendimiento;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inversiones"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Regresar a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Saldo disponible: \$${saldo.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            Text("Total Invertido: \$${totalInvertido.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
                "Rendimiento Acumulado: \$${rendimientoAcumulado.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, color: Colors.green)),
            SizedBox(height: 30),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Cantidad a invertir",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  montoInvertir = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: montoInvertir > 0 && montoInvertir <= saldo
                  ? () => invertirSaldo(montoInvertir)
                  : null,
              child: Text("Invertir"),
            ),
            SizedBox(height: 30),
            Text("Historial de Inversiones",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: historialInversiones.length,
                itemBuilder: (context, index) {
                  final inversion = historialInversiones[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                          "Monto: \$${(inversion['monto'] as num).toStringAsFixed(2)}"),
                      subtitle: Text("Fecha: ${inversion['fecha']}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
