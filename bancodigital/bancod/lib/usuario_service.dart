import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **📌 Cargar usuario autenticado desde SharedPreferences**
  Future<Map<String, dynamic>> cargarUsuario() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        print("⚠️ No se encontró un usuario autenticado en SharedPreferences.");
        return {};
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(userId).get();

      if (!userDoc.exists) {
        print("⚠️ Usuario no encontrado en Firestore.");
        return {};
      }

      var data = userDoc.data() as Map<String, dynamic>? ?? {};

      return {
        'nombre': data['nombre'] ?? "",
        'apellido': data['apellido'] ?? "",
        'saldo': (data['saldo'] as num?)?.toDouble() ?? 0.0,
        'numeroCuenta': data['numeroCuenta'] ?? "",
        'userId': userId,
      };
    } catch (e) {
      print("❌ Error al cargar usuario: $e");
      return {};
    }
  }

  /// **📌 Buscar usuario por número de cuenta en Firestore**
  Future<Map<String, dynamic>?> buscarCuenta(String numeroCuenta) async {
    try {
      print("🔍 Buscando cuenta con número: $numeroCuenta");

      QuerySnapshot snapshot = await _firestore
          .collection('usuarios')
          .where('numeroCuenta', isEqualTo: numeroCuenta)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("❌ No se encontró la cuenta.");
        return null;
      }

      var data = snapshot.docs.first.data() as Map<String, dynamic>? ?? {};
      return {
        'nombre': data['nombre'] ?? "",
        'apellido': data['apellido'] ?? "",
        'saldo': (data['saldo'] as num?)?.toDouble() ?? 0.0,
        'numeroCuenta': data['numeroCuenta'] ?? "",
        'userId': snapshot.docs.first.id,
      };
    } catch (e) {
      print("❌ Error al buscar la cuenta: $e");
      return null;
    }
  }

  /// **📌 Enviar dinero entre cuentas**
  Future<bool> enviarDinero(String cuentaDestino, double monto) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        print("❌ No hay usuario autenticado.");
        return false;
      }

      // Obtener datos del usuario que envía el dinero
      DocumentSnapshot usuarioOrigenDoc =
          await _firestore.collection('usuarios').doc(userId).get();

      if (!usuarioOrigenDoc.exists) {
        print("❌ Usuario origen no encontrado.");
        return false;
      }

      var datosOrigen = usuarioOrigenDoc.data() as Map<String, dynamic>? ?? {};
      double saldoOrigen = (datosOrigen['saldo'] as num?)?.toDouble() ?? 0.0;
      String numeroCuentaOrigen = datosOrigen['numeroCuenta'] ?? "";

      if (saldoOrigen < monto) {
        print("❌ Saldo insuficiente.");
        return false;
      }

      // Buscar usuario destino
      var usuarioDestino = await buscarCuenta(cuentaDestino);
      if (usuarioDestino == null) {
        print("❌ Cuenta destino no encontrada.");
        return false;
      }

      String userIdDestino = usuarioDestino['userId'];

      // Iniciar transacción para garantizar seguridad en la actualización de saldos
      return await _firestore.runTransaction((transaction) async {
        // Referencias de los documentos
        DocumentReference usuarioOrigenRef =
            _firestore.collection('usuarios').doc(userId);
        DocumentReference usuarioDestinoRef =
            _firestore.collection('usuarios').doc(userIdDestino);

        // Restar saldo al usuario origen
        transaction.update(usuarioOrigenRef, {
          'saldo': saldoOrigen - monto,
        });

        // Sumar saldo al usuario destino
        transaction.update(usuarioDestinoRef, {
          'saldo': FieldValue.increment(monto),
        });

        // Registrar transacción en una colección de historial
        _firestore.collection('transacciones').add({
          'emisorId': userId,
          'receptorId': userIdDestino,
          'numeroCuentaOrigen': numeroCuentaOrigen,
          'numeroCuentaDestino': cuentaDestino,
          'monto': monto,
          'fecha': FieldValue.serverTimestamp(),
        });

        print(
            "✅ Transferencia de \$${monto.toStringAsFixed(2)} realizada a ${usuarioDestino['nombre']} ${usuarioDestino['apellido']}.");
        return true;
      });
    } catch (e) {
      print("❌ Error en la transferencia: $e");
      return false;
    }
  }
}
