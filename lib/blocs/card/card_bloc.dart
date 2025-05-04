import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/models/card.dart';
import 'package:financial_app/repositories/card/card_repository.dart';

part 'card_event.dart';
part 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final CardRepository _cardRepository;
  CardBloc(this._cardRepository) : super(CardInitial()) {
    on<CardEvent>((event, emit) async {
      if (event is CardAddEvent) {
        try {
          emit(CardAddLoading());
          await _cardRepository.addCard(card: event.card);
          emit(CardAddSuccess());
        } catch (e) {
          emit(const CardAddError(message: 'Error while uploading'));
        }
      }
      if (event is CardFetchEvent) {
        try {
          emit(CardFetchLoading());
          final result = await _cardRepository.getCards(userID: event.userID);
          if (result.isNotEmpty) {
            emit(CardFetchLoaded(cards: result));
          } else {
            emit(CardFetchEmpty());
          }
        } catch (e) {
          emit(const CardFetchError(message: 'Error while fetching'));
        }
      }
      if (event is CardDeleteEvent) {
        try {
          emit(CardDeleteLoading());
          await _cardRepository.deleteCard(cardID: event.cardID);
          emit(CardDeleteSuccess());
        } catch (e) {
          emit(const CardDeleteError(message: 'Error while deleting'));
        }
      }
    });
  }
}
