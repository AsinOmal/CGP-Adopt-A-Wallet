part of 'shared_expense_bloc.dart';

sealed class SharedExpenseState extends Equatable {
  const SharedExpenseState();
  
  @override
  List<Object> get props => [];
}

final class SharedExpenseInitial extends SharedExpenseState {}

final class SharedExpenseLoading extends SharedExpenseState {}

final class SharedExpenseCreated extends SharedExpenseState {}

final class SharedExpenseError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
