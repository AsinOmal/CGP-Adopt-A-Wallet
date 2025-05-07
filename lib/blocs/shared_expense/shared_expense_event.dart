part of 'shared_expense_bloc.dart';

sealed class SharedExpenseEvent extends Equatable {
  const SharedExpenseEvent();

  @override
  List<Object> get props => [];
}

class SharedExpenseCreateRequest extends SharedExpenseEvent {
  final Group group;
  const SharedExpenseCreateRequest({
    required this.group,
  });

  @override
  List<Object> get props => [group];
}
