import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterStep2 extends StatefulWidget {
  final Function(String, String, String, String) onNext;

  RegisterStep2({required this.onNext, required void Function() onBack});

  @override
  _RegisterStep2State createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  String? selectedIngresos;
  String? selectedEgresos;
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  String selectedCountryCode = '+57'; // Código de Colombia por defecto
  PhoneNumber number = PhoneNumber(isoCode: 'CO');

  final List<String> ingresosEgresosList = [
    'Menos de \$500,000',
    '\$500,000 - \$1,000,000',
    '\$1,000,000 - \$2,000,000',
    '\$2,000,000 - \$5,000,000',
    'Más de \$5,000,000'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.5),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paso 2: Información Financiera',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Ingresos
                  DropdownButtonFormField<String>(
                    value: selectedIngresos,
                    items: ingresosEgresosList
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedIngresos = value),
                    decoration: InputDecoration(
                      labelText: 'Ingresos',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Egresos
                  DropdownButtonFormField<String>(
                    value: selectedEgresos,
                    items: ingresosEgresosList
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedEgresos = value),
                    decoration: InputDecoration(
                      labelText: 'Egresos',
                      prefixIcon: Icon(Icons.money_off),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Dirección
                  TextFormField(
                    controller: direccionController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Teléfono separado (Indicativo + Número)
                  Row(
                    children: [
                      // Selector de indicativo de país
                      Container(
                        width: 110, // Ajusta el ancho del selector
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            setState(() {
                              selectedCountryCode = number.dialCode ?? '+57';
                            });
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          ),
                          ignoreBlank: true,
                          autoValidateMode: AutovalidateMode.disabled,
                          initialValue: number,
                          textFieldController:
                              TextEditingController(text: selectedCountryCode),
                          inputDecoration: InputDecoration(
                            labelText: 'Indicativo',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          formatInput: false, // Evita errores de formato
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(width: 10),

                      // Campo de número de teléfono
                      Expanded(
                        child: TextFormField(
                          controller: telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Número de teléfono',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Botón siguiente con validaciones
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      if (selectedIngresos == null || selectedEgresos == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Por favor complete todos los campos obligatorios.')),
                        );
                        return;
                      }
                      if (telefonoController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ingrese un número válido')),
                        );
                        return;
                      }
                      widget.onNext(
                        selectedIngresos!,
                        selectedEgresos!,
                        direccionController.text.trim(),
                        "$selectedCountryCode ${telefonoController.text.trim()}",
                      );
                    },
                    child: Text('Siguiente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
