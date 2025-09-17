import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'usuario_service.dart';
import 'tarjeta_service.dart';
import 'agregar_tarjeta_page.dart';

class TarjetasPage extends StatefulWidget {
  @override
  _TarjetasPageState createState() => _TarjetasPageState();
}

class _TarjetasPageState extends State<TarjetasPage> {
  String? userId, nombre, apellido;
  bool isLoading = true;
  final UsuarioService usuarioService = UsuarioService();
  final TarjetaService tarjetaService = TarjetaService();

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    var userData = await usuarioService.cargarUsuario();
    setState(() {
      userId = userData['userId'];
      nombre = userData['nombre'];
      apellido = userData['apellido'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Mis Tarjetas", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : nombre == null || apellido == null
              ? Center(child: Text("Error al cargar usuario."))
              : StreamBuilder<QuerySnapshot>(
                  stream: tarjetaService.obtenerTarjetas(nombre!, apellido!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text("No tienes tarjetas aún.",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var tarjeta = snapshot.data!.docs[index];
                        return Dismissible(
                          key: Key(tarjeta.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: Icon(Icons.delete,
                                color: Colors.white, size: 30),
                          ),
                          onDismissed: (_) => tarjetaService.eliminarTarjeta(
                              context, tarjeta.id),
                          child: _tarjetaItem(tarjeta),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarTarjetaPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }

  Widget _tarjetaItem(QueryDocumentSnapshot tarjeta) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          "•••• •••• •••• ${tarjeta['numero'].split(' ')[3]}",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              "Titular: ${tarjeta['nombre']} ${tarjeta['apellido']}",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 5),
            Text(
              "Vence: ${tarjeta['fecha_vencimiento']}",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.content_copy, color: Colors.white70),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: tarjeta['numero']));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Número copiado al portapapeles")),
            );
          },
        ),
      ),
    );
  }
}
