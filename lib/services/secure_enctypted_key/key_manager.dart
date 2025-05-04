import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class KeyManager {
  final _secureStorage = const FlutterSecureStorage();
  static const _keyStorageKey = 'encryption_key';
  static const _ivStorageKey = 'encryption_iv';

  // Generate a random key for AES encryption (256-bit key)
  Future<void> generateAndStoreKey() async {
    // Generate a secure 32-character key
    const secureRandomKey = '12345678901234567890123456789012';
    await _secureStorage.write(key: _keyStorageKey, value: secureRandomKey);

    // Generate and store a random IV
    final iv = encrypt.IV.fromUtf8('1234567890123456');
    await _secureStorage.write(key: _ivStorageKey, value: iv.base64);
  }

  // Retrieve the encryption key
  Future<String> getEncryptionKey() async {
    final key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null) {
      throw Exception('Encryption key not found. Please generate one.');
    }
    return key;
  }

  // Retrieve the IV
  Future<String> getEncryptionIV() async {
    final iv = await _secureStorage.read(key: _ivStorageKey);
    if (iv == null) {
      throw Exception('Encryption IV not found. Please generate one.');
    }
    return iv;
  }
}
