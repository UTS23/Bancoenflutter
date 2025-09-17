import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesario para el formateo
import 'package:bancod/service.dart';
import 'package:bancod/configuracion_page.dart';
import 'package:bancod/agregar_tarjeta_page.dart';
import 'package:bancod/depositar_page.dart';
import 'package:bancod/retirar_page.dart';
import 'package:bancod/enviar.dart';
import 'saldo_widget.dart';
import 'opciones_grid.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  double saldo = 0.0;
  bool isLoading = true;
  bool mostrarSaldo = true;
  final UserService _userService = UserService();
  Timer? _timer;
  int _selectedIndex = 0;
  String fechaHora = '';
  String numeroCuenta = '';

  @override
  void initState() {
    super.initState();
    cargarUsuario();
    _iniciarActualizacionSaldo();
    _actualizarFechaHora();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _actualizarFechaHora();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarActualizacionSaldo() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      cargarUsuario();
    });
  }

  void _actualizarFechaHora() {
    setState(() {
      fechaHora = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    });
  }

  Future<void> cargarUsuario() async {
    var userData = await _userService.getUserData();
    if (userData != null) {
      setState(() {
        userName = userData['nombre'] ?? 'Usuario';
        saldo = userData['saldo'] ?? 0.0;
        numeroCuenta =
            userData['numeroCuenta'] ?? ''; // Obtener el número de cuenta
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _mostrarOpciones(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Formatea el saldo para agregar puntos cada 3 dígitos
  String _formatSaldo(double saldo) {
    final format = NumberFormat('#,###', 'es_ES');
    return format.format(saldo); // Aquí se formatea el saldo
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      OpcionesGrid(),
      ConfiguracionPage(),
      Container(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Esto elimina la flecha de retroceso
        title: Text(userName.isNotEmpty ? userName : 'Banco Digital'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                fechaHora,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de saldo
                  SaldoWidget(
                    saldo: mostrarSaldo ? saldo : 0.0,
                    mostrarSaldo: mostrarSaldo,
                    onToggleSaldo: () {
                      setState(() {
                        mostrarSaldo = !mostrarSaldo;
                      });
                    },
                    numeroCuenta: numeroCuenta, // Aquí pasamos el numeroCuenta
                    saldoFormateado:
                        _formatSaldo(saldo), // Pasamos el saldo formateado
                  ),
                  SizedBox(height: 20),
                  Expanded(child: _screens[_selectedIndex]),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: "Ajustes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, size: 30),
            label: "Más",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }

  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Opciones Rápidas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              _buildOptionTile(
                icon: Icons.credit_card,
                title: "Agregar Tarjeta",
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AgregarTarjetaPage()),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.account_balance_wallet,
                title: "Depositar",
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DepositarPage()),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.money_off,
                title: "Retirar",
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RetirarPage()),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.send,
                title: "Enviar Dinero",
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EnviarDineroPage()),
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }
}

class SaldoWidget extends StatelessWidget {
  final double saldo;
  final bool mostrarSaldo;
  final VoidCallback onToggleSaldo;
  final String numeroCuenta;
  final String saldoFormateado;

  const SaldoWidget({
    Key? key,
    required this.saldo,
    required this.mostrarSaldo,
    required this.onToggleSaldo,
    required this.numeroCuenta,
    required this.saldoFormateado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saldo en la parte superior
            Row(
              children: [
                Text(
                  "Saldo: ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  mostrarSaldo ? saldoFormateado : "****",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: onToggleSaldo,
                  child: Icon(
                    mostrarSaldo ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Número de cuenta debajo del saldo
            Text(
              "Número de Cuenta: $numeroCuenta",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
