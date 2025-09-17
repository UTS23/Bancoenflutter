import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene los datos del usuario desde Firestore usando el `userId` almacenado en SharedPreferences.
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        print("❌ No se encontró un `userId` en SharedPreferences.");
        return null;
      }

      print("📌 Recuperando datos de Firestore para userId: $userId");

      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(userId).get();

      if (!userDoc.exists) {
        print("❌ El usuario con ID $userId no existe en Firestore.");
        return null;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print("✅ Datos del usuario obtenidos: $userData");
      return userData;
    } catch (e) {
      print("⚠️ Error al obtener datos del usuario: $e");
      return null;
    }
  }
}
