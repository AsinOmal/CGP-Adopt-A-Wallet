part of 'card_bloc.dart';

sealed class CardState extends Equatable {
  const CardState();

  @override
  List<Object> get props => [];
}

final class CardInitial extends CardState {}

final class CardAddLoading extends CardState {}

final class CardAddSuccess extends CardState {}

final class CardAddError extends CardState {
  final String message;
  const CardAddError({required this.message});

  @override
  List<Object> get props => [message];
}

final class CardFetchLoading extends CardState {}

final class CardDeleteLoading extends CardState {}

final class CardDeleteSuccess extends CardState {}

final class CardDeleteError extends CardState {
  final String message;
  const CardDeleteError({required this.message});

  @override
  List<Object> get props => [message];
}

final class CardFetchEmpty extends CardState {}

final class CardFetchLoaded extends CardState {
  final List<Card> cards;

  const CardFetchLoaded({required this.cards});
  @override
  List<Object> get props => [cards];
}

final class CardFetchError extends CardState {
  final String message;
  const CardFetchError({required this.message});

  @override
  List<Object> get props => [message];
}
