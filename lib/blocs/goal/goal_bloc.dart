import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/models/goal.dart';
import 'package:financial_app/repositories/goal/goal_repository.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository _goalRepository;

  GoalBloc(this._goalRepository) : super(GoalInitial()) {
    on<GoalEvent>((event, emit) async {
      if (event is GoalAddEvent) {
        try {
          emit(GoalLoading());
          await _goalRepository.addGoal(goal: event.goal);
          emit(GoalSuccess());
        } catch (e) {
          emit(const GoalAddError(message: 'Error occurred!'));
        }
      }
      if (event is GoalFetchEvent) {
        try {
          emit(GoalFetchLoading());
          final goals = await _goalRepository.getGoals(userID: event.userID);
          if (goals.isNotEmpty) {
            emit(GoalLoaded(goals: goals));
          } else {
            emit(GoalsEmpty());
          }
        } catch (e) {
          emit(const GoalFetchError(message: 'Goals fetching error!'));
        }
      }
      if (event is GoalUpdateEvent) {
        try {
          emit(GoalUpdateLoading());
          await _goalRepository.updateGoal(
              goalID: event.goalID, goal: event.goal);
          emit(GoalUpdateSuccess());
        } catch (e) {
          emit(const GoalUpdateError(message: 'Goal fetching error!'));
        }
      }

      if (event is GoalDeleteEvent) {
        try {
          await _goalRepository.deleteGoal(goalID: event.goalID);
        } catch (e) {
          emit(const GoalDeleteError(message: 'Goal deleting error'));
        }
      }
    });
  }
}
