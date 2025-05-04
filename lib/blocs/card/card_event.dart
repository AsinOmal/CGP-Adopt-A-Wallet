part of 'card_bloc.dart';

sealed class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object> get props => [];
}

class CardAddEvent extends CardEvent {
  final Card card;
  const CardAddEvent({required this.card});

  @override
  List<Object> get props => [card];
}

class CardFetchEvent extends CardEvent {
  final String userID;
  const CardFetchEvent({required this.userID});

  @override
  List<Object> get props => [userID];
}

class CardDeleteEvent extends CardEvent {
  final String cardID;
  const CardDeleteEvent({required this.cardID});

  @override
  List<Object> get props => [cardID];
}
