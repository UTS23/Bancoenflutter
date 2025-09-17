import 'package:bancod/home.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart'; // 📅 Para formatear la fecha

class FacturaPage extends StatelessWidget {
  final String cuentaDestino;
  final String destinatario;
  final double monto;
  final String concepto;
  final String fecha; // 📅 Nueva variable para la fecha

  FacturaPage({
    required this.cuentaDestino,
    required this.destinatario,
    required this.monto,
    required this.concepto,
  }) : fecha = DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.now()); // 📅 Genera la fecha actual

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ❌ Bloquea el botón de retroceso
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Factura"),
          backgroundColor: Colors.blueGrey, // Azul oscuro
          centerTitle: true,
          automaticallyImplyLeading: false, // ❌ Elimina la flecha de atrás
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Factura de Transferencia",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Tarjeta con la información de la factura
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8, // Sombra más suave
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow("Fecha:", fecha),
                        _buildInfoRow("Cuenta destino:", cuentaDestino),
                        _buildInfoRow("Destinatario:", destinatario),
                        _buildInfoRow("Monto:",
                            "\$${NumberFormat('#,###', 'en_US').format(monto)}"),
                        _buildInfoRow("Concepto:", concepto),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Contenedor con código QR y marca de agua
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Código QR
                      QrImageView(
                        data:
                            "Fecha: $fecha | Cuenta: $cuentaDestino | Destinatario: $destinatario | Monto: \$${NumberFormat('#,###', 'en_US').format(monto)} | Concepto: $concepto",
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                      ),
                      // Marca de agua
                      Positioned(
                        bottom: 10,
                        child: Opacity(
                          opacity:
                              0.1, // Controla la visibilidad de la marca de agua
                          child: const Text(
                            "Banco Digital",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Botón para compartir factura
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.green, // Botón verde
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    "Compartir Factura",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () {
                    // Implementar compartir factura
                  },
                ),

                const SizedBox(height: 20),

                // Botón para regresar al inicio
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.redAccent, // Botón rojo
                  ),
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text(
                    "Regresar al Inicio",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget reutilizable para mostrar información con formato claro
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
