import 'package:flutter/material.dart';

class DatosPersonales extends StatelessWidget {
  final Map<String, dynamic>? userData;

  DatosPersonales({required this.userData});

  @override
  Widget build(BuildContext context) {
    return _buildList([
      _buildInfoTile(Icons.person, "Nombre", userData?['nombre']),
      _buildInfoTile(Icons.badge, "Apellido", userData?['apellido']),
      _buildInfoTile(
          Icons.credit_card, "Tipo de Documento", userData?['tipo_documento']),
      _buildInfoTile(Icons.perm_identity, "Número de Documento",
          userData?['numero_documento']),
    ]);
  }

  Widget _buildList(List<Widget> tiles) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(children: tiles),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String? value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text(value ?? 'No disponible', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
