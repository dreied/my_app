import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationService {
  static final _storage = const FlutterSecureStorage();
  // Usage limit counters
  static const _keyProductCount = "product_count";
  static const _keySalesCount = "sales_count";
  static const _keyCustomerCount = "customer_count";

  static const _keyActivated = "activated";
  static const _keyDeviceSeed = "device_seed";
  static const _keyExpiry = "activation_expiry";

  // YOUR REAL RSA PUBLIC KEY (SAFE TO EMBED)
  static const String _publicKeyPem = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtGt97b+dHjPLH9oXfcmi
tDlwCje039AkS6k0pEdUHnif9MWyVROKkJl6L+A87NcajGQHygxWVpTGu5JcdftX
AYB7gJLOs4k504uS//dCcIgUTQU0i3PYH43UkF/47hVnbZh7bCqPggNW0qz4yZTW
GUNM3ja1Hoo9iEiBbKd2gzWbI+gfLJbkbpO5VVimgZxWu2IKAmKHqS8e5XIJqkPm
gde1HeUatM3QS6JLN4bOQzLhiN1Ws3d76mubqsiqpWQXAPNBVEr56kMdlAx2slVl
g1cO0IRTB9l4U2WPqIbbemQTn6+/HycoFqpHkpH5p9Vk1wM70NJqtC46dORog2KN
kwIDAQAB
-----END PUBLIC KEY-----
""";

  static Future<RSAPublicKey> _loadPublicKey() async {
    return CryptoUtils.rsaPublicKeyFromPem(_publicKeyPem);
  }

  /// Generate device fingerprint (unchanged)
 static Future<String> getFingerprint() async {
  final deviceInfo = DeviceInfoPlugin();
  final android = await deviceInfo.androidInfo;

  // Load or create device seed
  String? seed = await _storage.read(key: _keyDeviceSeed);
  if (seed == null) {
    seed = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _keyDeviceSeed, value: seed);
  }

  // Fix unreliable Android ID
  String androidId = android.id ?? "";
  if (androidId.isEmpty ||
      androidId == "unknown" ||
      androidId == "9774d56d682e549c") {
    androidId = "fallback-$seed";
  }

  final raw = "$androidId|${android.model}|${android.manufacturer}|$seed";
  final hash = sha256.convert(utf8.encode(raw)).toString();
  final fingerprint = hash.substring(0, 32);

  debugPrint("=== Activation Debug (my_app) ===");
  debugPrint("Android ID: $androidId");
  debugPrint("Raw fingerprint input: $raw");
  debugPrint("Hashed fingerprint (first 32 chars): $fingerprint");
  debugPrint("===============================");

  return fingerprint;
}


  static Future<bool> _verifySignature({
    required String fingerprint,
    required String codeBase64Url,
  }) async {
    try {
      final pubKey = await _loadPublicKey();

      final signer = Signer("SHA-256/RSA");
      final pubParams = PublicKeyParameter<RSAPublicKey>(pubKey);
      signer.init(false, pubParams);

      final messageBytes = Uint8List.fromList(utf8.encode(fingerprint));
      final sigBytes = base64Url.decode(codeBase64Url.trim());
      final signature = RSASignature(sigBytes);

      final ok = signer.verifySignature(messageBytes, signature);

      debugPrint("=== Activation Debug (my_app) ===");
      debugPrint("Fingerprint used for verification: $fingerprint");
      debugPrint("Code (Base64URL) entered: $codeBase64Url");
      debugPrint("Signature bytes length: ${sigBytes.length}");
      debugPrint("Verification result: $ok");
      debugPrint("===============================");

      return ok;
    } catch (e) {
      debugPrint("Activation verification error: $e");
      return false;
    }
  }

  /// Validate activation code + set expiry (1 year)
  static Future<bool> validate(String code) async {
    final fp = await getFingerprint();

    final isValid = await _verifySignature(
      fingerprint: fp,
      codeBase64Url: code,
    );

    if (isValid) {
      await _storage.write(key: _keyActivated, value: "true");

      final expiry = DateTime.now().add(const Duration(days: 365));
      await _storage.write(key: _keyExpiry, value: expiry.toIso8601String());

      debugPrint("Activation successful. Expiry set to $expiry");
      return true;
    }

    debugPrint("Activation failed.");
    return false;
  }

  /// Check if activation is valid and not expired
  static Future<bool> isActivated() async {
    final active = await _storage.read(key: _keyActivated);
    if (active != "true") return false;

    final expiryStr = await _storage.read(key: _keyExpiry);
    if (expiryStr == null) return false;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;

    if (DateTime.now().isAfter(expiry)) {
      await _storage.write(key: _keyActivated, value: "false");
      return false;
    }

    return true;
  }

  /// Get expiry date (for UI)
  static Future<DateTime?> getExpiryDate() async {
    final expiryStr = await _storage.read(key: _keyExpiry);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  

  // -------------------------------------------------------------
  // USAGE LIMITS (5 products, 5 sales, 2 customers)
  // -------------------------------------------------------------
  static Future<int> getProductCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyProductCount) ?? 0;
  }

  static Future<int> getSalesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySalesCount) ?? 0;
  }

  static Future<int> getCustomerCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCustomerCount) ?? 0;
  }

  static Future<void> incrementProduct() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_keyProductCount, (prefs.getInt(_keyProductCount) ?? 0) + 1);
  }

  static Future<void> incrementSale() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_keySalesCount, (prefs.getInt(_keySalesCount) ?? 0) + 1);
  }

  static Future<void> incrementCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_keyCustomerCount, (prefs.getInt(_keyCustomerCount) ?? 0) + 1);
  }

  static Future<void> _resetLimits() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_keyProductCount, 0);
    prefs.setInt(_keySalesCount, 0);
    prefs.setInt(_keyCustomerCount, 0);
  }
}

