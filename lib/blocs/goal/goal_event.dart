part of 'goal_bloc.dart';

sealed class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object> get props => [];
}

class GoalAddEvent extends GoalEvent {
  final Goal goal;

  const GoalAddEvent({required this.goal});

  @override
  List<Object> get props => [goal];
}

class GoalFetchEvent extends GoalEvent {
  final String userID;

  const GoalFetchEvent({required this.userID});

  @override
  List<Object> get props => [userID];
}

class GoalUpdateEvent extends GoalEvent {
  final String goalID;
  final Goal goal;

  const GoalUpdateEvent({required this.goalID, required this.goal});

  @override
  List<Object> get props => [goal, goalID];
}

class GoalDeleteEvent extends GoalEvent {
  final String goalID;

  const GoalDeleteEvent({required this.goalID});

  @override
  List<Object> get props => [goalID];
}
