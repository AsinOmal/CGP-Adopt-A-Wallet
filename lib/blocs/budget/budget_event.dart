part of 'budget_bloc.dart';

sealed class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class BudgetAddEvent extends BudgetEvent {
  final Budget budget;
  const BudgetAddEvent({required this.budget});

  @override
  List<Object> get props => [budget];
}

class BudgetFetchEvent extends BudgetEvent {
  final String userID;

  const BudgetFetchEvent({required this.userID});

  @override
  List<Object> get props => [userID];
}

class BudgetDeleteEvent extends BudgetEvent {
  final String budgetID;
  const BudgetDeleteEvent({required this.budgetID});

  @override
  List<Object> get props => [budgetID];
}

class BudgetUpdateEvent extends BudgetEvent {
  final String budgetID;
  final Budget budget;
  const BudgetUpdateEvent({
    required this.budget,
    required this.budgetID,
  });

  @override
  List<Object> get props => [budget, budgetID];
}
