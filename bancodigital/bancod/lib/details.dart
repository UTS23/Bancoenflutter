import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetalleTransaccionScreen extends StatelessWidget {
  final Map<String, dynamic> transaccion;

  DetalleTransaccionScreen({required this.transaccion});

  @override
  Widget build(BuildContext context) {
    bool esEnviado = transaccion['tipo'] == 'envio';

    String fechaFormateada = "Fecha no disponible";
    if (transaccion['fecha'] is String) {
      try {
        DateTime fecha = DateTime.parse(transaccion['fecha']);
        fechaFormateada = DateFormat('dd/MM/yyyy, hh:mm a').format(fecha);
      } catch (e) {
        print("Error al parsear la fecha: $e");
      }
    }

    String montoFormateado =
        NumberFormat('#,##0.00', 'es_ES').format(transaccion['monto'] ?? 0.0);

    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Detalle de Transacción"),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    esEnviado ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                    color: esEnviado ? Colors.redAccent : Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    esEnviado
                        ? "Transferencia Enviada"
                        : "Transferencia Recibida",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "\$$montoFormateado",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: esEnviado ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  _infoRow("📅 Fecha", fechaFormateada),
                  SizedBox(height: 10),
                  _infoRow(
                      esEnviado ? "👤 Cuenta destino" : "👤 Cuenta origen",
                      esEnviado
                          ? transaccion['numeroCuentaDestino']
                          : transaccion['numeroCuentaOrigen']),
                  _infoRow(
                      esEnviado ? "🔐 Cuenta origen" : "🔐 Cuenta destino",
                      esEnviado
                          ? transaccion['numeroCuentaOrigen']
                          : transaccion['numeroCuentaDestino']),
                  SizedBox(height: 20),
                  Divider(),
                  Text(
                    "💼 Esta transacción está vigilada por la Superintendencia Financiera.",
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "📞 ¿Necesitas ayuda? Llama al 316 512 5962",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        Text(
          value ?? "-",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
        ),
      ],
    );
  }
}
