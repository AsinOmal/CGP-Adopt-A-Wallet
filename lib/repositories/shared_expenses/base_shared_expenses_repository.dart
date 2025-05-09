import 'package:financial_app/enums/user_group_status.dart';
import 'package:financial_app/models/group.dart';
import 'package:financial_app/models/group_expense.dart';
import 'package:financial_app/models/group_invite.dart';

abstract class BaseSharedExpensesRepository {
  Future<void> addSharedExpenseGroup({required Group group});

  Future<void> sendGroupInvite({required GroupInvite groupInvite});

  Future<bool> isUserInGroup(String userId, String groupId);

  Future<List<Group>> fetchGroups({required String userId });

  Future<UserGroupStatus> fetchUserByEmailCheckIsInGroup({required String email, required String groupId});

  Future<bool> sendGroupInviteToUser({required String email, required String groupId, required String senderId});

  Future<void> addExpenseToGroup({required GroupExpense groupExpense, required String groupId});

  Future<List<GroupExpense>> fetchGroupExpenses({required String groupId});

  Future<void> deleteSharedExpenseGroup({required String groupId});

  Future<List<GroupInvite>> fetchGroupInvites({required String userId});
}
