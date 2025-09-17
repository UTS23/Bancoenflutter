import 'package:flutter/material.dart';

class DatosFinancieros extends StatelessWidget {
  final Map<String, dynamic>? userData;

  DatosFinancieros({required this.userData});

  @override
  Widget build(BuildContext context) {
    return _buildList([
      _buildInfoTile(
          Icons.account_balance, "Número de Cuenta", userData?['numeroCuenta']),
      _buildInfoTile(Icons.attach_money, "Saldo", "\$${userData?['saldo']}"),
      _buildInfoTile(Icons.trending_up, "Ingresos", userData?['ingresos']),
      _buildInfoTile(Icons.trending_down, "Egresos", userData?['egresos']),
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
