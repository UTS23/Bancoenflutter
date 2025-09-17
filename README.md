
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

  <img width="485" height="606" alt="image" src="https://github.com/user-attachments/assets/6958e84c-059d-4f9b-ade7-0c81ec4486f0" />
   <img width="485" height="617" alt="image" src="https://github.com/user-attachments/assets/329c578a-9e4b-4e17-95f6-cc324644112c" />
   <img width="478" height="600" alt="image" src="https://github.com/user-attachments/assets/0677eeb9-db12-42d5-a26a-9b4e1cc34be7" />
   <img width="515" height="624" alt="image" src="https://github.com/user-attachments/assets/e15e208b-eb83-47c6-bd66-0e7eee5b2ad0" />
   <img width="486" height="612" alt="image" src="https://github.com/user-attachments/assets/1e3f4f98-be38-40e2-878a-8e1f3814a5ce" />
   <img width="499" height="568" alt="image" src="https://github.com/user-attachments/assets/3c796dce-4b0f-4fad-8ca4-2f7a08dc94c8" />
   <img width="508" height="549" alt="image" src="https://github.com/user-attachments/assets/718dceeb-4319-458d-a69f-ee8ef0f3002e" />
   <img width="494" height="618" alt="image" src="https://github.com/user-attachments/assets/724b4109-932b-44f1-bcb2-25c2919faf4c" />
   <img width="498" height="623" alt="image" src="https://github.com/user-attachments/assets/80b45771-fb34-4576-99e0-2138b1ba5de4" />
   <img width="492" height="624" alt="image" src="https://github.com/user-attachments/assets/3488f2cc-3e61-45f6-8f60-6a2b5fd22fca" />
   <img width="497" height="615" alt="image" src="https://github.com/user-attachments/assets/c19f2267-84b9-4165-9130-ac2133ee23ad" />

   <img width="490" height="616" alt="image" src="https://github.com/user-attachments/assets/b55cfaf3-6c18-4b17-9606-3503afa6e5f0" />

   <img width="497" height="639" alt="image" src="https://github.com/user-attachments/assets/7e52a986-704b-4aee-a038-2e6cbf92f9b2" />

