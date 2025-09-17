import 'package:cloud_firestore/cloud_firestore.dart';

class PrestamoService {
  Future<double> getSaldo(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['saldo'] ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print("Error al cargar saldo: $e");
      return 0.0;
    }
  }

  Future<void> solicitarPrestamo(String userId, double monto, int plazo) async {
    try {
      await FirebaseFirestore.instance.collection('prestamos').add({
        'userId': userId,
        'monto': monto,
        'plazo': plazo,
        'fechaSolicitud': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al solicitar el préstamo: $e");
    }
  }

  Future<List<Map<String, dynamic>>> loadPrestamos(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('prestamos')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'monto': doc['monto'],
          'plazo': doc['plazo'],
          'fechaSolicitud': doc['fechaSolicitud'],
        };
      }).toList();
    } catch (e) {
      throw "Error al cargar los préstamos: $e";
    }
  }
}
