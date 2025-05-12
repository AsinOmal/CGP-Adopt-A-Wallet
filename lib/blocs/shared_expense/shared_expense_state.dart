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

//create a states for group fetching
final class SharedExpenseGroupsFetched extends SharedExpenseState {
  final List<Group> groups;

  const SharedExpenseGroupsFetched({required this.groups});

  @override
  List<Object> get props => [groups];
}

//create a states for group fetching loading and error
final class SharedExpenseGroupsLoading extends SharedExpenseState {}

final class SharedExpenseGroupsError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseGroupsError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

//create a states for fectching user by email
final class SharedExpenseUserFetched extends SharedExpenseState {
  final UserGroupStatus userGroupStatus;

  const SharedExpenseUserFetched({required this.userGroupStatus});

  @override
  List<Object> get props => [userGroupStatus];
}

final class SharedExpenseUserLoading extends SharedExpenseState {}

final class SharedExpenseUserError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseUserError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class SharedExpenseGroupInviteSent extends SharedExpenseState {}

final class SharedExpenseGroupInviteError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseGroupInviteError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

// create sharedexpenseadded states
final class SharedExpenseAdded extends SharedExpenseState {}

final class SharedExpenseAddedError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseAddedError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class SharedExpenseAddedLoading extends SharedExpenseState {}

// creates state for fetch sharedexpenses
final class SharedExpenseFetched extends SharedExpenseState {
  final List<GroupExpense> groupExpenses;

  const SharedExpenseFetched({required this.groupExpenses});

  @override
  List<Object> get props => [groupExpenses];
}

final class SharedExpenseFetchSharedExpensesLoading
    extends SharedExpenseState {}

final class SharedExpenseFetchSharedExpensesError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseFetchSharedExpensesError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class SharedExpenseGroupDeleted extends SharedExpenseState {}

final class SharedExpenseDeleteGroupError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseDeleteGroupError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class SharedExpenseGroupInviteFetched extends SharedExpenseState {
  final List<GroupInvite> invites;

  const SharedExpenseGroupInviteFetched({required this.invites});

  @override
  List<Object> get props => [invites];
}

final class SharedExpenseGroupInvitesError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseGroupInvitesError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class SharedExpenseGroupInvitesLoading extends SharedExpenseState {}

final class SharedExpenseGroupInviteResponseSuccess extends SharedExpenseState {
  final bool accepted;

  const SharedExpenseGroupInviteResponseSuccess({required this.accepted});

  @override
  List<Object> get props => [accepted];
}

final class SharedExpenseGroupInviteResponseError extends SharedExpenseState {
  final String errorMessage;

  const SharedExpenseGroupInviteResponseError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
