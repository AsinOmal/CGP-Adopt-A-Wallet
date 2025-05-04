import 'package:financial_app/models/card.dart';

abstract class BaseCardRepository {
  Future<void> addCard({required Card card});

  Future<List<Card>> getCards({required String userID});

  Future<void> deleteCard({required String cardID});
}
