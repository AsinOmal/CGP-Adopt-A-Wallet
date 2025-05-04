import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/models/card.dart';
import 'package:financial_app/repositories/card/base_card_repository.dart';
import 'package:financial_app/services/secure_enctypted_key/encrypted_helper.dart';
import 'dart:developer' as dev;
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:financial_app/services/secure_enctypted_key/key_manager.dart';

class CardRepository extends BaseCardRepository {
  final CollectionReference _cardCollection =
      FirebaseFirestore.instance.collection('cards');
  final keyManager = KeyManager();

  @override
  Future<void> addCard({required Card card}) async {
    try {
      final encryptionKey = await keyManager.getEncryptionKey();
      final ivBase64 = await keyManager.getEncryptionIV();
      final encryptionHelper = EncryptionHelper(
        encrypt.Key.fromUtf8(encryptionKey),
        encrypt.IV.fromBase64(ivBase64),
      );

      final doc = _cardCollection.doc();
      card.id = doc.id;
      card.cardNumber = encryptionHelper.encryptData(card.cardNumber);
      card.cvv = encryptionHelper.encryptData(card.cvv);
      card.expireDate = encryptionHelper.encryptData(card.expireDate);

      await doc.set(card.toJson());
      dev.log('Card added successfully');
    } catch (e) {
      dev.log('Card add error ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> deleteCard({required String cardID}) async {
    try {
      await _cardCollection.doc(cardID).delete();
      dev.log('Card delete succeess');
    } catch (e) {
      dev.log('Card delete error');
      rethrow;
    }
  }

  @override
  Future<List<Card>> getCards({required String userID}) async {
    try {
      final encryptionKey = await keyManager.getEncryptionKey();
      final ivBase64 = await keyManager.getEncryptionIV();
      final encryptionHelper = EncryptionHelper(
        encrypt.Key.fromUtf8(encryptionKey),
        encrypt.IV.fromBase64(ivBase64),
      );

      final querySnapshot = await _cardCollection
          .where('userID', isEqualTo: userID)
          .orderBy('createdAt', descending: true)
          .get();

      dev.log('Cards retrieved successfully');

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final card = Card.fromJson(data);

        // Decrypt sensitive fields
        card.cardNumber = encryptionHelper.decryptData(card.cardNumber);
        card.cvv = encryptionHelper.decryptData(card.cvv);
        card.expireDate = encryptionHelper.decryptData(card.expireDate);

        return card;
      }).toList();
    } catch (e) {
      dev.log('Cards retrieval error: ${e.toString()}');
      rethrow;
    }
  }
}
