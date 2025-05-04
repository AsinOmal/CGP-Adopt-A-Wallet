import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/models/budget.dart';
import 'package:financial_app/repositories/budget/budget_repository.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;

  BudgetBloc(this._budgetRepository) : super(BudgetInitial()) {
    on<BudgetEvent>(
      (event, emit) async {
        if (event is BudgetAddEvent) {
          try {
            emit(BudgetLoading());
            await _budgetRepository.addBugdet(budget: event.budget);
            emit(BudgetSuccess());
          } catch (e) {
            if (e
                .toString()
                .contains('A budget for this category already exists.')) {
              emit(const BudgetError(
                  message: 'A budget for this category already exists.'));
              return;
            }
            emit(const BudgetError(
                message: 'Error while uploading to database'));
          }
        }
        if (event is BudgetFetchEvent) {
          try {
            emit(BudgetFetchLoading());
            final budgets =
                await _budgetRepository.getBudgets(userID: event.userID);
            if (budgets.isNotEmpty) {
              await Future.delayed(const Duration(milliseconds: 500));
              emit(BudgetFetchLoaded(budgets: budgets));
            } else {
              await Future.delayed(const Duration(milliseconds: 500));
              emit(BudgetsEmpty());
            }
          } catch (e) {
            await Future.delayed(const Duration(milliseconds: 500));
            emit(const BudgetFetchError(
                message: 'Error while fetching from database'));
          }
        }
        if (event is BudgetDeleteEvent) {
          try {
            await _budgetRepository.deleteBudget(budgetID: event.budgetID);
          } catch (e) {
            emit(const BudgetDeleteError(
                message: 'Error while deleting from database'));
          }
        }
        if (event is BudgetUpdateEvent) {
          try {
            emit(BudgetUpdateLoading());
            await _budgetRepository.updateBudget(
                budgetID: event.budgetID, budget: event.budget);
            emit(BudgetUpdateSuccess());
          } catch (e) {
            emit(const BudgetUpdateError(
                message: 'Error while updating from database'));
          }
        }
      },
    );
  }
}
