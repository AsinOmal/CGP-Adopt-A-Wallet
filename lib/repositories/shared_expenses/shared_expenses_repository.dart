import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/enums/user_group_status.dart';
import 'package:financial_app/models/group.dart';
import 'package:financial_app/models/group_expense.dart';
import 'package:financial_app/models/group_invite.dart';
import 'package:financial_app/repositories/shared_expenses/base_shared_expenses_repository.dart';
import 'dart:developer' as dev;

class SharedExpensesRepository extends BaseSharedExpensesRepository {
  final CollectionReference _sharedExpenseGroupCollection =
      FirebaseFirestore.instance.collection('shared_expense_groups');

  final CollectionReference _groupInviteCollection =
      FirebaseFirestore.instance.collection('group_invites');

  @override
  Future<void> addSharedExpenseGroup({required Group group}) async {
    try {
      final doc = _sharedExpenseGroupCollection.doc();
      group.id = doc.id;
      await doc.set(group.toJson());
      dev.log('Shared expense group added successfully');
    } catch (e) {
      dev.log("Shared expense group add error: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<void> sendGroupInvite({required GroupInvite groupInvite}) async {
    try {
      final doc = _groupInviteCollection.doc();
      groupInvite.id = doc.id;
      await doc.set(groupInvite.toJson());
      dev.log('Group invite sent successfully');
    } catch (e) {
      dev.log("Group invite send error: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<bool> isUserInGroup(String userId, String groupId) async {
    try {
      final groupDoc = await _sharedExpenseGroupCollection.doc(groupId).get();
      if (groupDoc.exists) {
        final groupData = groupDoc.data() as Map<String, dynamic>;
        final memberIds = List<String>.from(groupData['memberIds'] ?? []);
        return memberIds.contains(userId);
      }
      return false;
    } catch (e) {
      dev.log("Error checking if user is in group: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<List<Group>> fetchGroups({required String userId}) {
    try {
      return _sharedExpenseGroupCollection
          .where('memberIds', arrayContains: userId)
          .get()
          .then((snapshot) {
        return snapshot.docs.map((doc) {
          return Group.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      dev.log("Error fetching groups: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<UserGroupStatus> fetchUserByEmailCheckIsInGroup(
      {required String email, required String groupId}) async {
    try {
      // Fetch user by email
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Check if user exists
      if (userQuery.docs.isEmpty) {
        dev.log('No user found with the provided email');
        return UserGroupStatus.notFound;
      }

      final userId = userQuery.docs.first.id;

      // Check if user is already in the group
      final isInGroup = await isUserInGroup(userId, groupId);
      if (isInGroup) {
        dev.log('User is already a member of this group');
        return UserGroupStatus.inGroup;
      }

      // Check if user has been invited to the group
      final inviteQuery = await _groupInviteCollection
          .where('recipientId', isEqualTo: userId)
          .where('groupId', isEqualTo: groupId)
          .limit(1)
          .get();

      if (inviteQuery.docs.isNotEmpty) {
        dev.log('User has already been invited to this group');
        return UserGroupStatus.invited;
      }

      // User exists and can be invited to the group
      dev.log('User found and available to invite');
      return UserGroupStatus.available;
    } catch (e) {
      dev.log("Error checking user group status: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<bool> sendGroupInviteToUser(
      {required String email,
      required String groupId,
      required String senderId}) async {
    try {
      // Fetch user by email
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      final userId = userQuery.docs.first.id;

      // Create a new group invite
      final groupInvite = GroupInvite(
        id: '',
        recipientId: userId,
        senderId: senderId,
        groupId: groupId,
        isAccepted: null,
        createdAt: DateTime.now(),
      );

      // Send the group invite
      await sendGroupInvite(groupInvite: groupInvite);
      return true;
    } catch (e) {
      dev.log("Error sending group invite to user: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<void> addExpenseToGroup(
      {required GroupExpense groupExpense, required String groupId}) async {
    try {
      final groupDoc = _sharedExpenseGroupCollection.doc(groupId);

      // Create a map from the expense without an ID
      final expenseMap = groupExpense.toJson();

      // Update the group document to add the expense to its expenses array
      await groupDoc.update({
        'expenses': FieldValue.arrayUnion([expenseMap])
      });

      dev.log('Expense added to group successfully');
    } catch (e) {
      dev.log("Error adding expense to group: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<List<GroupExpense>> fetchGroupExpenses(
      {required String groupId}) async {
    try {
      final groupDoc = await _sharedExpenseGroupCollection.doc(groupId).get();
      if (!groupDoc.exists) {
        return [];
      }

      final groupData = groupDoc.data() as Map<String, dynamic>;
      final expenses = groupData['expenses'] as List<dynamic>? ?? [];

      // Convert the expenses to GroupExpense objects and sort by createdAt
      final groupExpenses = expenses
          .map((expenseMap) => GroupExpense.fromJson(expenseMap))
          .toList();

      // Sort by createdAt (newest first)
      groupExpenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return groupExpenses;
    } catch (e) {
      dev.log("Error fetching group expenses: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<void> deleteSharedExpenseGroup({required String groupId}) async {
    try {
      await _sharedExpenseGroupCollection.doc(groupId).delete();
      final groupInviteQuery = await _groupInviteCollection
          .where('groupId', isEqualTo: groupId)
          .get();
      for (var doc in groupInviteQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      dev.log("Error deleting shared expense group: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<List<GroupInvite>> fetchGroupInvites({required String userId}) {
    try {
      return _groupInviteCollection
          .where('recipientId', isEqualTo: userId)
          .get()
          .then((snapshot) {
        return snapshot.docs.map((doc) {
          return GroupInvite.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      dev.log("Error fetching group invites: ${e.toString()}");
      rethrow;
    }
  }
}
