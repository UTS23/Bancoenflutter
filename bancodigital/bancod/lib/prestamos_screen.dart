import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl

class PrestamosScreen extends StatefulWidget {
  @override
  _PrestamosScreenState createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _plazoController = TextEditingController();
  late String userId;
  double saldo = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Cargar el userId desde SharedPreferences
  _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
    // Cargar el saldo del usuario desde Firestore
    if (userId.isNotEmpty) {
      _loadSaldo();
    }
  }

  // Cargar el saldo actual del usuario
  _loadSaldo() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          saldo = userDoc['saldo'] ?? 0.0;
        });
      }
    } catch (e) {
      print("Error al cargar saldo: $e");
    }
  }

  // Actualizar el saldo del usuario en Firestore
  _actualizarSaldo(double monto) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({
        'saldo': FieldValue.increment(monto), // Incrementa el saldo del usuario
      });
    } catch (e) {
      print("Error al actualizar saldo: $e");
    }
  }

  // Enviar la solicitud de préstamo
  void _solicitarPrestamo() async {
    if (_montoController.text.isEmpty || _plazoController.text.isEmpty) {
      _showInfoDialog("Por favor, complete todos los campos.");
      return;
    }

    double monto = double.tryParse(_montoController.text) ?? 0;
    int plazo = int.tryParse(_plazoController.text) ?? 0;

    if (monto <= 0 || plazo <= 0) {
      _showInfoDialog("Monto o plazo no válidos.");
      return;
    }

    if (userId.isNotEmpty) {
      // Registra el préstamo en Firestore para el solicitante
      FirebaseFirestore.instance.collection('prestamos').add({
        'userId': userId,
        'monto': monto,
        'plazo': plazo,
        'fechaSolicitud': FieldValue.serverTimestamp(),
      }).then((_) {
        // Actualiza el saldo del solicitante
        _actualizarSaldo(monto);

        // Llamar a _loadPrestamos nuevamente para actualizar la lista después de un nuevo préstamo
        setState(() {});
      }).catchError((e) {
        _showInfoDialog("Error al solicitar el préstamo: $e");
      });
    } else {
      _showInfoDialog("No se encontró el ID de usuario.");
    }
  }

  // Mostrar un cuadro de diálogo de información
  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Información"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Cargar los préstamos desde Firestore
  Future<List<Map<String, dynamic>>> _loadPrestamos() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('prestamos')
          .where('userId',
              isEqualTo: userId) // Filtra los préstamos por el userId
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'monto': doc['monto'],
          'plazo': doc['plazo'],
          'fechaSolicitud':
              doc['fechaSolicitud'], // Marca de tiempo de la fecha
        };
      }).toList();
    } catch (e) {
      throw "Error al cargar los préstamos: $e";
    }
  }

  // Formatear la fecha de solicitud
  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('d \'de\' MMMM \'de\' yyyy, h:mm:ss a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestión de Préstamos")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Asegura que la pantalla sea ajustable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección para mostrar el saldo actual
              Text(
                "Saldo Actual: \$${saldo.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Sección para solicitar un préstamo
              Text(
                "Solicitar un préstamo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _montoController,
                decoration: InputDecoration(
                  labelText: "Monto del préstamo",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _plazoController,
                decoration: InputDecoration(
                  labelText: "Plazo (meses)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _solicitarPrestamo,
                  child: Text("Solicitar"),
                ),
              ),
              SizedBox(height: 30),
              // Sección para visualizar los préstamos solicitados
              Text(
                "Tus préstamos",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Usando FutureBuilder para mostrar los préstamos
              FutureBuilder<List<Map<String, dynamic>>>(
                // Maneja la carga de los préstamos
                future: _loadPrestamos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text("No tienes préstamos solicitados."));
                  } else {
                    var prestamos = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: prestamos.length,
                      itemBuilder: (context, index) {
                        var prestamo = prestamos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text("Monto: \$${prestamo['monto']}"),
                            subtitle: Text(
                              "Plazo: ${prestamo['plazo']} meses\nFecha: ${_formatDate(prestamo['fechaSolicitud'])}",
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
