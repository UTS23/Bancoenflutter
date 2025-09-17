import 'package:bancod/details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class TransaccionesScreen extends StatefulWidget {
  @override
  _TransaccionesScreenState createState() => _TransaccionesScreenState();
}

class _TransaccionesScreenState extends State<TransaccionesScreen> {
  String? numeroCuentaUsuario;

  @override
  void initState() {
    super.initState();
    _obtenerNumeroCuentaUsuario();
  }

  Future<void> _obtenerNumeroCuentaUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('usuarios').doc(userId).get();

    if (!userDoc.exists) return;

    setState(() {
      numeroCuentaUsuario =
          (userDoc.data() as Map<String, dynamic>?)?['numeroCuenta'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text("Mis Transacciones"),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: numeroCuentaUsuario == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('transacciones')
                  .where(Filter.or(
                    Filter('numeroCuentaOrigen',
                        isEqualTo: numeroCuentaUsuario),
                    Filter('numeroCuentaDestino',
                        isEqualTo: numeroCuentaUsuario),
                  ))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text("No tienes transacciones aún.",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                var transacciones = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: transacciones.length,
                  itemBuilder: (context, index) {
                    var data =
                        transacciones[index].data() as Map<String, dynamic>;
                    bool esEnviado =
                        data['numeroCuentaOrigen'] == numeroCuentaUsuario;
                    Color colorFondo = esEnviado
                        ? Colors.redAccent.withOpacity(0.1)
                        : Colors.greenAccent.withOpacity(0.1);
                    IconData icono =
                        esEnviado ? Icons.arrow_upward : Icons.arrow_downward;
                    Color colorIcono = esEnviado ? Colors.red : Colors.green;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalleTransaccionScreen(transaccion: data),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorFondo,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(icono, color: colorIcono),
                          ),
                          title: Text(
                            esEnviado
                                ? "Enviado a: ${data['numeroCuentaDestino']}"
                                : "Recibido de: ${data['numeroCuentaOrigen']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Fecha: ${_formatFecha(data['fecha'])}",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            "\$${(data['monto'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: esEnviado ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatFecha(Timestamp? fecha) {
    if (fecha == null) return "Sin fecha";
    final date = fecha.toDate();
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final hora = date.hour.toString().padLeft(2, '0');
    final minutos = date.minute.toString().padLeft(2, '0');
    return "$dia/$mes/${date.year} $hora:$minutos";
  }
}
