part of 'goal_bloc.dart';

sealed class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object> get props => [];
}

final class GoalInitial extends GoalState {}

final class GoalsEmpty extends GoalState {}

final class GoalLoading extends GoalState {}

final class GoalFetchLoading extends GoalState {}

final class GoalUpdateLoading extends GoalState {}

final class GoalSuccess extends GoalState {}

final class GoalUpdateSuccess extends GoalState {}

final class GoalAddError extends GoalState {
  final String message;
  const GoalAddError({required this.message});

  @override
  List<Object> get props => [message];
}

final class GoalFetchError extends GoalState {
  final String message;
  const GoalFetchError({required this.message});

  @override
  List<Object> get props => [message];
}

final class GoalDeleteError extends GoalState {
  final String message;
  const GoalDeleteError({required this.message});

  @override
  List<Object> get props => [message];
}

final class GoalUpdateError extends GoalState {
  final String message;
  const GoalUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

final class GoalLoaded extends GoalState {
  final List<Goal> goals;

  const GoalLoaded({required this.goals});

  @override
  List<Object> get props => [goals];
}
