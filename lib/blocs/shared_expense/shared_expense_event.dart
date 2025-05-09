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

class SharedExpenseFetchGroupsRequest extends SharedExpenseEvent {
  final String userId;
  const SharedExpenseFetchGroupsRequest({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class SharedExpenseFetchUserByEmailRequest extends SharedExpenseEvent {
  final String email;
  final String groupId;
  const SharedExpenseFetchUserByEmailRequest({
    required this.email,
    required this.groupId,
  });

  @override
  List<Object> get props => [email, groupId];
}

class SharedExpenseSendInviteRequest extends SharedExpenseEvent {
  final String email;
  final String groupId;
  final String senderId;
  const SharedExpenseSendInviteRequest({
    required this.email,
    required this.groupId,
    required this.senderId,
  });

  @override
  List<Object> get props => [email, groupId, senderId];
}

class SharedExpenseAddExpenseRequest extends SharedExpenseEvent {
  final GroupExpense groupExpense;
  final String groupId;
  const SharedExpenseAddExpenseRequest({
    required this.groupExpense,
    required this.groupId,
  });

  @override
  List<Object> get props => [groupExpense, groupId];
}

class SharedExpensesFetchRequest extends SharedExpenseEvent {
  final String groupId;
  const SharedExpensesFetchRequest({
    required this.groupId,
  });

  @override
  List<Object> get props => [groupId];
}

class SharedExpenseDeleteGroupRequest extends SharedExpenseEvent {
  final String groupId;
  const SharedExpenseDeleteGroupRequest({
    required this.groupId,
  });

  @override
  List<Object> get props => [groupId];
}

class SharedExpenseFetchGroupInvitesRequest extends SharedExpenseEvent {
  final String userId;
  const SharedExpenseFetchGroupInvitesRequest({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}