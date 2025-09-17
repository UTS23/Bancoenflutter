import 'package:bancod/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mi_informacion_page.dart';
import 'cambio_clave_page.dart';

class ConfiguracionPage extends StatefulWidget {
  @override
  _ConfiguracionPageState createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _isLoggingOut = false;

  Future<void> _cerrarSesion(BuildContext context) async {
    bool confirmacion = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Advertencia"),
        content: Text("¿Estás seguro de que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Aceptar"),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      setState(() => _isLoggingOut = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cerrando sesión en 5 segundos..."),
          duration: Duration(seconds: 5),
        ),
      );

      await Future.delayed(Duration(seconds: 5));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId'); // Obtiene el userId
      print("Cerrando sesión del usuario con ID: $userId");

      await prefs.clear(); // Elimina los datos de sesión

      setState(() => _isLoggingOut = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text('Mi Información'),
                subtitle: Text('Ver y actualizar tu información personal'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MiInformacionPage()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.lock, color: Colors.green),
                title: Text('Cambio de Clave'),
                subtitle: Text('Actualizar tu contraseña'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CambioClavePage()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.orange),
                title: Text('Ajustes Generales'),
                subtitle: Text('Configurar opciones generales'),
                onTap: () {
                  // Aquí puedes agregar otra pantalla en el futuro
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Cerrar Sesión'),
                onTap: () => _cerrarSesion(context),
              ),
            ],
          ),
          if (_isLoggingOut)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Cerrando sesión...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
