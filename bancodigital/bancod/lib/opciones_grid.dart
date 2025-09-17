import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bancod/otros_screen.dart';
import 'package:bancod/prestamos_screen.dart';
import 'package:bancod/transacciones_screen.dart';

class OpcionesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Esto elimina la flecha de retroceso
        title: const Text('Opciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _showRightPanel(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildOptionCard(
              icon: Icons.monetization_on,
              title: "Préstamos",
              onTap: () => _navigateTo(context, PrestamosScreen()),
            ),
            _buildOptionCard(
              icon: Icons.category,
              title: "Otros",
              onTap: () => _navigateTo(context, OtrosScreen()),
            ),
            _buildOptionCard(
              icon: Icons.swap_horiz,
              title: "Transacciones",
              onTap: () => _navigateTo(context, TransaccionesScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **Panel lateral derecho flotante con las últimas 3 transacciones**
  void _showRightPanel(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Opciones",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.monetization_on,
                        color: Colors.blueAccent),
                    title: const Text("Préstamos"),
                    onTap: () => _navigateTo(context, PrestamosScreen()),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.category, color: Colors.blueAccent),
                    title: const Text("Otros"),
                    onTap: () => _navigateTo(context, OtrosScreen()),
                  ),
                  _buildTransaccionesTile(context),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cerrar",
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildTransaccionesTile(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _obtenerUltimasTransacciones(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: Icon(Icons.swap_horiz, color: Colors.blueAccent),
            title: Text("Transacciones"),
            subtitle: Text("Cargando..."),
          );
        }
        if (snapshot.hasError) {
          return const ListTile(
            leading: Icon(Icons.error, color: Colors.redAccent),
            title: Text("Error al cargar transacciones"),
          );
        }

        List<Map<String, dynamic>> transacciones = snapshot.data ?? [];

        return ExpansionTile(
          leading: const Icon(Icons.swap_horiz, color: Colors.blueAccent),
          title: const Text("Transacciones"),
          children: transacciones.map((transaccion) {
            return ListTile(
              title: Text(
                transaccion['tipo'] == 'enviado'
                    ? "Enviado a: ${transaccion['destino']}"
                    : "Recibido de: ${transaccion['origen']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Fecha: ${transaccion['fecha']}"),
              trailing: Text(
                "\$${transaccion['monto']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onExpansionChanged: (expanded) {
            if (expanded) {
              _navigateTo(context, TransaccionesScreen());
            }
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerUltimasTransacciones() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) return [];

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc =
          await firestore.collection('usuarios').doc(userId).get();

      if (!userDoc.exists) return [];

      String numeroCuentaUsuario = userDoc.get('numeroCuenta') ?? '';

      QuerySnapshot query = await firestore
          .collection('transacciones')
          .where('numeroCuentaOrigen', isEqualTo: numeroCuentaUsuario)
          .orderBy('fecha', descending: true)
          .limit(3)
          .get();

      return query.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error al obtener transacciones: $e");
      return [];
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
