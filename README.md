
---

# BancoD

BancoD es una **aplicación bancaria móvil** desarrollada en **Flutter** y utilizando **Firebase** como backend. La aplicación permite a los usuarios gestionar sus cuentas, realizar transacciones, consultar balances y llevar un control de sus finanzas de manera segura y eficiente.

## Características

* Registro y autenticación de usuarios mediante **número de teléfono** o información personalizada.
* Consulta de **saldo y movimientos** de la cuenta.
* **Transferencias** entre cuentas de la misma plataforma.
* Historial de transacciones detallado.
* Interfaz **amigable y moderna** con enfoque en experiencia de usuario (UX).
* Almacenamiento seguro de datos mediante **Firebase Cloud Firestore**.
* Gestión de sesión local con **SharedPreferences**.

## Tecnologías utilizadas

* **Flutter**: Para el desarrollo multiplataforma (Android & iOS).
* **Firebase**:

  * **Cloud Firestore**: Base de datos NoSQL en la nube.
  * **Firebase Authentication**: Opcional, si se desea seguridad adicional.
* **SharedPreferences**: Para manejo de sesiones de usuario.
* **Dart**: Lenguaje principal del desarrollo Flutter.

## Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/UTS23/BancoD.git
   ```
2. Accede al directorio del proyecto:

   ```bash
   cd BancoD
   ```
3. Instala las dependencias de Flutter:

   ```bash
   flutter pub get
   ```
4. Configura Firebase:

   * Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
   * Añade tu aplicación de Flutter (Android/iOS).
   * Descarga los archivos de configuración:

     * `google-services.json` para Android.
     * `GoogleService-Info.plist` para iOS.
   * Colócalos en sus respectivas carpetas del proyecto.
5. Ejecuta la aplicación:

   ```bash
   flutter run
   ```

## Configuración de Firestore

Se recomienda crear las siguientes colecciones en Firebase:

* `clientes`

  * Campos: `nombre`, `apellido`, `telefono`, `correo`, `contraseña`, `saldo`, `status`
* `transacciones`

  * Campos: `idCliente`, `tipo`, `monto`, `fecha`, `descripcion`

> Nota: La contraseña se puede almacenar en **hash** para mayor seguridad, aunque en este proyecto inicial se usa directamente para simplificación.

## Uso

* Al abrir la aplicación, el usuario puede registrarse o iniciar sesión.
* Una vez dentro, puede consultar su saldo, ver historial de transacciones y realizar transferencias a otros usuarios registrados.
* La información de la sesión se guarda localmente, evitando que el usuario tenga que iniciar sesión cada vez.

## Contribuciones

Si deseas contribuir al proyecto:

1. Haz un fork del repositorio.
2. Crea una nueva rama:

   ```bash
   git checkout -b feature/nombre-de-tu-funcion
   ```
3. Realiza tus cambios y haz commit:

   ```bash
   git commit -m "Descripción de los cambios"
   ```
4. Envía tus cambios al repositorio remoto:

   ```bash
   git push origin feature/nombre-de-tu-funcion
   ```
5. Abre un Pull Request describiendo tus cambios.

## Licencia

