part of 'budget_bloc.dart';

sealed class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object> get props => [];
}

final class BudgetInitial extends BudgetState {}

final class BudgetLoading extends BudgetState {}

final class BudgetSuccess extends BudgetState {}

final class BudgetUpdateSuccess extends BudgetState {}

final class BudgetUpdateError extends BudgetState {
  final String message;
  const BudgetUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

final class BudgetUpdateLoading extends BudgetState {}

final class BudgetError extends BudgetState {
  final String message;
  const BudgetError({required this.message});

  @override
  List<Object> get props => [message];
}

final class BudgetFetchLoading extends BudgetState {}

final class BudgetsEmpty extends BudgetState {}

final class BudgetFetchLoaded extends BudgetState {
  final List<Budget> budgets;

  const BudgetFetchLoaded({required this.budgets});

  @override
  List<Object> get props => [budgets];
}

final class BudgetFetchError extends BudgetState {
  final String message;
  const BudgetFetchError({required this.message});

  @override
  List<Object> get props => [message];
}

final class BudgetDeleteError extends BudgetState {
  final String message;
  const BudgetDeleteError({required this.message});

  @override
  List<Object> get props => [message];
}
