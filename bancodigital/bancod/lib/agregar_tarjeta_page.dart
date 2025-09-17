import 'dart:math';
import 'package:bancod/targetas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AgregarTarjetaPage extends StatefulWidget {
  @override
  _AgregarTarjetaPageState createState() => _AgregarTarjetaPageState();
}

class _AgregarTarjetaPageState extends State<AgregarTarjetaPage> {
  String nombre = '';
  String apellido = '';
  String numeroTarjeta = '';
  String fechaVencimiento = '';
  String cvc = '';
  bool isLoading = true;
  bool tarjetaGenerada = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          nombre = userDoc['nombre'] ?? '';
          apellido = userDoc['apellido'] ?? '';
          isLoading = false;
        });
      }
    }
  }

  void _generarTarjeta() {
    Random random = Random();

    // Generar número de tarjeta con formato "1234 5678 9012 3456"
    List<String> partes = [];
    for (int i = 0; i < 4; i++) {
      partes.add(random.nextInt(9999).toString().padLeft(4, '0'));
    }

    // Generar fecha de vencimiento en formato MM/YY
    int mes = random.nextInt(12) + 1;
    int anio = DateTime.now().year + random.nextInt(5) + 1;
    String mesStr = mes.toString().padLeft(2, '0');
    String anioStr = anio.toString().substring(2);

    setState(() {
      numeroTarjeta = partes.join(' ');
      fechaVencimiento = '$mesStr/$anioStr';
      cvc = random.nextInt(900).toString().padLeft(3, '0');
      tarjetaGenerada = true;
    });
  }

  Future<void> _guardarTarjeta() async {
    if (!tarjetaGenerada) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Genera una tarjeta primero"),
            backgroundColor: Colors.red),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('tarjetas').add({
      'nombre': nombre,
      'apellido': apellido,
      'numero': numeroTarjeta,
      'fecha_vencimiento': fechaVencimiento,
      'cvc': cvc,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Tarjeta guardada exitosamente"),
          backgroundColor: Colors.green),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Tarjeta')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  tarjetaGenerada
                      ? _buildTarjetaPreview()
                      : _buildTarjetaPlaceholder(),
                  SizedBox(height: 20),
                  _buildButton(
                    onPressed: _generarTarjeta,
                    text: "Generar Tarjeta",
                    icon: Icons.credit_card,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 10),
                  _buildButton(
                    onPressed: _guardarTarjeta,
                    text: "Guardar Tarjeta",
                    icon: Icons.save,
                    color: Colors.green,
                  ),
                  SizedBox(height: 10),
                  _buildTextButton(
                    text: "Volver",
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                  _buildTextButton(
                    text: "Ver mis tarjetas",
                    icon: FontAwesomeIcons.wallet,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TarjetasPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTarjetaPreview() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 32),
          SizedBox(height: 10),
          Text(
            "•••• •••• •••• ${numeroTarjeta.split(' ')[3]}",
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("$nombre $apellido",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Vence: $fechaVencimiento",
                  style: TextStyle(fontSize: 14, color: Colors.white70)),
              Text("CVC: $cvc",
                  style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaPlaceholder() {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text(
          "Genera tu tarjeta",
          style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _buildButton(
      {required VoidCallback onPressed,
      required String text,
      required IconData icon,
      required Color color}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildTextButton(
      {required String text,
      required IconData icon,
      required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.blueAccent),
      label:
          Text(text, style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
    );
  }
}
