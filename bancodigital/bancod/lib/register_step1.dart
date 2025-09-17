import 'package:flutter/material.dart';

class RegisterStep1 extends StatefulWidget {
  final Function(String, String, int, String, String) onNext;

  RegisterStep1({required this.onNext});

  @override
  _RegisterStep1State createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController documentoController = TextEditingController();
  String selectedDocType = 'Cédula'; // Valor por defecto para evitar errores
  int selectedAge = 18;

  final List<int> ageList = List.generate(83, (index) => index + 18);
  final List<String> docTypes = [
    'Cédula',
    'Pasaporte',
    'Permiso de Protección Temporal'
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      widget.onNext(
        nameController.text.trim(),
        lastNameController.text.trim(),
        selectedAge,
        selectedDocType,
        documentoController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Oculta el teclado
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Paso 1: Información Básica',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Ingrese su nombre' : null,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Ingrese su apellido' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedAge,
                      items: ageList
                          .map((age) =>
                              DropdownMenuItem(value: age, child: Text('$age')))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedAge = value!),
                      decoration: InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDocType,
                      items: docTypes
                          .map((doc) =>
                              DropdownMenuItem(value: doc, child: Text(doc)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedDocType = value!),
                      decoration: InputDecoration(
                        labelText: 'Tipo de Documento',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null
                          ? 'Seleccione un tipo de documento'
                          : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: documentoController,
                      decoration: InputDecoration(
                        labelText: 'Número de Documento',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.trim().isEmpty
                          ? 'Ingrese su número de documento'
                          : null,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      onPressed: _validateAndProceed,
                      child: Text('Siguiente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
