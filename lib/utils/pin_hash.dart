import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinHash {
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  static bool verify(String pin, String hashed) {
    return hashPin(pin) == hashed;
  }
}
