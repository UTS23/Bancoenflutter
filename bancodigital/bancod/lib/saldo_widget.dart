import 'package:flutter/material.dart';

class SaldoWidget extends StatelessWidget {
  final double saldo;
  final String numeroCuenta;
  final bool mostrarSaldo;
  final VoidCallback onToggleSaldo;

  const SaldoWidget({
    required this.saldo,
    required this.numeroCuenta,
    required this.mostrarSaldo,
    required this.onToggleSaldo,
    required String saldoFormateado,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Saldo Disponible:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mostrarSaldo ? "\$${saldo.toStringAsFixed(2)}" : "••••••",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    mostrarSaldo ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onToggleSaldo,
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Número de Cuenta: $numeroCuenta",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
