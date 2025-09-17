import 'package:bancod/datocon.dart';
import 'package:bancod/datofin.dart';
import 'package:bancod/datoinfo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiInformacionPage extends StatefulWidget {
  @override
  _MiInformacionPageState createState() => _MiInformacionPageState();
}

class _MiInformacionPageState extends State<MiInformacionPage> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String? userId;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarInformacionUsuario();
  }

  Future<void> _cargarInformacionUsuario() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');

      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Información')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(child: Text('No se pudo cargar la información.'))
              : _getScreen(currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Personal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: 'Finanzas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail), label: 'Contacto'),
        ],
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return DatosPersonales(userData: userData);
      case 1:
        return DatosFinancieros(userData: userData);
      case 2:
        return DatosContacto(
          userData: userData,
          userId: userId,
          onFechaSeleccionada: (String) {},
        );
      default:
        return DatosPersonales(userData: userData);
    }
  }
}
