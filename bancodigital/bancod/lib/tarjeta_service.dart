import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TarjetaService {
  Stream<QuerySnapshot> obtenerTarjetas(String nombre, String apellido) {
    return FirebaseFirestore.instance
        .collection('tarjetas')
        .where('nombre', isEqualTo: nombre)
        .where('apellido', isEqualTo: apellido)
        .snapshots();
  }

  Future<void> eliminarTarjeta(BuildContext context, String id) async {
    bool confirmar = await _confirmarEliminacion(context);
    if (confirmar) {
      await FirebaseFirestore.instance.collection('tarjetas').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tarjeta eliminada")),
      );
    }
  }

  Future<bool> _confirmarEliminacion(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Eliminar Tarjeta"),
                content: Text("¿Estás seguro de que deseas eliminar esta tarjeta?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Eliminar", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
