import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatosContacto extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Function(String) onFechaSeleccionada;

  DatosContacto(
      {required this.userData,
      required this.onFechaSeleccionada,
      String? userId});

  @override
  Widget build(BuildContext context) {
    return _buildList([
      _buildInfoTile(Icons.phone, "Teléfono", userData?['telefono'], context),
      _buildInfoTile(
          Icons.email, "Correo Electrónico", userData?['email'], context),
      _buildInfoTile(
          Icons.location_on, "Dirección", userData?['direccion'], context),
      _buildDateTile(Icons.cake, "Fecha de Nacimiento",
          userData?['fecha_nacimiento'], "fecha_nacimiento", context),
      _buildDateTile(Icons.event, "Fecha de Expedición",
          userData?['fecha_expedicion'], "fecha_expedicion", context),
    ]);
  }

  Widget _buildList(List<Widget> tiles) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(children: tiles),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String title, String? value, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? '¿Es correcta esta información?',
            style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildDateTile(IconData icon, String title, dynamic value,
      String campo, BuildContext context) {
    String dateText = "No disponible";
    if (value is Timestamp) {
      dateText = DateFormat('dd/MM/yyyy').format(value.toDate());
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(dateText, style: TextStyle(fontSize: 16)),
        onTap: () async {
          DateTime? selectedDate = await _selectDate(context, campo);
          if (selectedDate != null) {
            _actualizarFechaEnFirestore(campo, selectedDate);
          }
        },
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, String campo) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:
          campo == 'fecha_expedicion' && userData?['fecha_nacimiento'] != null
              ? (userData!['fecha_nacimiento'] as Timestamp).toDate()
              : DateTime(1900),
      lastDate: DateTime.now(),
    );
    return selectedDate;
  }

  Future<void> _actualizarFechaEnFirestore(String campo, DateTime fecha) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({
        campo: Timestamp.fromDate(fecha),
      });
    }
  }
}
