import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  String password = "941023";
  String hashed = sha256.convert(utf8.encode(password)).toString();
  print("Hash generado: $hashed");
}
