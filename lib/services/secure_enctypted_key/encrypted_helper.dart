import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  final encrypt.Key key;
  final encrypt.IV iv;

  EncryptionHelper(this.key, this.iv);

  String encryptData(String data) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(data, iv: iv).base64;
  }

  String decryptData(String encryptedData) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt64(encryptedData, iv: iv);
  }
}
