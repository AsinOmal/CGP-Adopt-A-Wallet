import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/enums/user_group_status.dart';
import 'package:financial_app/models/group.dart';
import 'package:financial_app/models/group_expense.dart';
import 'package:financial_app/models/group_invite.dart';
import 'package:financial_app/repositories/shared_expenses/shared_expenses_repository.dart';
import 'dart:developer' as dev;

part 'shared_expense_event.dart';
part 'shared_expense_state.dart';

class SharedExpenseBloc extends Bloc<SharedExpenseEvent, SharedExpenseState> {
  final SharedExpensesRepository _sharedExpensesRepository;

  SharedExpenseBloc(this._sharedExpensesRepository)
      : super(SharedExpenseInitial()) {
    on<SharedExpenseEvent>((event, emit) async {
      if (event is SharedExpenseCreateRequest) {
        try {
          emit(SharedExpenseLoading());
          await _sharedExpensesRepository.addSharedExpenseGroup(
              group: event.group);
          emit(SharedExpenseCreated());
        } catch (e) {
          emit(const SharedExpenseError(
              errorMessage: "Failed to create shared expense group"));
        }
      }
      if (event is SharedExpenseFetchGroupsRequest) {
        try {
          emit(SharedExpenseGroupsLoading());
          final groups =
              await _sharedExpensesRepository.fetchGroups(userId: event.userId);
          emit(SharedExpenseGroupsFetched(groups: groups));
        } catch (e) {
          dev.log("Error fetching groups: ${e.toString()}");
          emit(const SharedExpenseGroupsError(
              errorMessage: "Failed to fetch shared expense groups"));
        }
      }
      if (event is SharedExpenseFetchUserByEmailRequest) {
        try {
          emit(SharedExpenseUserLoading());
          final userGroupStatus =
              await _sharedExpensesRepository.fetchUserByEmailCheckIsInGroup(
                  email: event.email, groupId: event.groupId);
          emit(SharedExpenseUserFetched(userGroupStatus: userGroupStatus));
        } catch (e) {
          emit(const SharedExpenseUserError(
              errorMessage: "Failed to fetch user by email"));
        }
      }
      if (event is SharedExpenseSendInviteRequest) {
        try {
          final isInviteSent =
              await _sharedExpensesRepository.sendGroupInviteToUser(
                  email: event.email,
                  groupId: event.groupId,
                  senderId: event.senderId);
          if (isInviteSent) {
            emit(SharedExpenseGroupInviteSent());
          } else {
            emit(const SharedExpenseGroupInviteError(
                errorMessage: "Failed to send group invite"));
          }
        } catch (e) {
          emit(const SharedExpenseGroupInviteError(
              errorMessage: "Failed to send group invite"));
        }
      }
      if (event is SharedExpenseAddExpenseRequest) {
        try {
          emit(SharedExpenseAddedLoading());
          await _sharedExpensesRepository.addExpenseToGroup(
              groupExpense: event.groupExpense, groupId: event.groupId);
          emit(SharedExpenseAdded());
        } catch (e) {
          emit(const SharedExpenseAddedError(
              errorMessage: "Failed to add expense to group"));
        }
      }
      if (event is SharedExpensesFetchRequest) {
        try {
          emit(SharedExpenseFetchSharedExpensesLoading());
          final groupExpenses = await _sharedExpensesRepository
              .fetchGroupExpenses(groupId: event.groupId);
          emit(SharedExpenseFetched(groupExpenses: groupExpenses));
        } catch (e) {
          emit(const SharedExpenseFetchSharedExpensesError(
              errorMessage: "Failed to fetch group expenses"));
        }
      }
      if (event is SharedExpenseDeleteGroupRequest) {
        try {
          await _sharedExpensesRepository.deleteSharedExpenseGroup(
              groupId: event.groupId);
          emit(SharedExpenseGroupDeleted());
        } catch (e) {
          emit(const SharedExpenseDeleteGroupError(
              errorMessage: "Failed to delete group"));
        }
      }
      if (event is SharedExpenseFetchGroupInvitesRequest) {
        try {
          emit(SharedExpenseGroupInvitesLoading());
          final groupInvites = await _sharedExpensesRepository
              .fetchGroupInvites(userId: event.userId);
          emit(SharedExpenseGroupInviteFetched(invites: groupInvites));
        } catch (e) {
          emit(const SharedExpenseGroupInvitesError(
              errorMessage: "Failed to fetch group invites"));
        }
      }
    });
  }
}
