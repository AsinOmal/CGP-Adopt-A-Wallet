import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/models/group.dart';
import 'package:financial_app/repositories/shared_expenses/shared_expenses_repository.dart';

part 'shared_expense_event.dart';
part 'shared_expense_state.dart';

class SharedExpenseBloc extends Bloc<SharedExpenseEvent, SharedExpenseState> {
  final SharedExpensesRepository _sharedExpensesRepository;

  SharedExpenseBloc(this._sharedExpensesRepository) : super(SharedExpenseInitial()) {
    on<SharedExpenseEvent>((event, emit) async {
      if(event is SharedExpenseCreateRequest){
        try {
          emit(SharedExpenseLoading());
          await _sharedExpensesRepository.addSharedExpenseGroup(group: event.group);
          emit(SharedExpenseCreated());
        } catch (e) {
          emit(const SharedExpenseError(errorMessage: "Failed to create shared expense group"));
        }
      }
    });
  }
}
