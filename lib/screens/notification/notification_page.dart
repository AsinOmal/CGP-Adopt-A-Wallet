import 'package:financial_app/blocs/shared_expense/shared_expense_bloc.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/group_invite.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool? isAccepted;
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Bill Reminder',
      'description': 'Your electricity bill is due on 25th October.',
      'date': 'Today',
      'isRead': false,
    },
  ];

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true; // Update the isRead property
      }
    });
  }

  late SharedExpenseBloc _sharedExpenseBloc;
  late AuthRepository _authRepository;

  @override
  void initState() {
    _sharedExpenseBloc = RepositoryProvider.of<SharedExpenseBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _sharedExpenseBloc.add(
        SharedExpenseFetchGroupInvitesRequest(userId: _authRepository.userID));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('notifications'),
          style: const TextStyle(fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            BlocBuilder(
              builder: (context, state) {
                if (state is SharedExpenseGroupInviteFetched) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.invites.length,
                      itemBuilder: (context, index) {
                        final groupInvite = state.invites[index];
                        return _buildGroupInviteCard(groupInvite);
                      },
                    ),
                  );
                } else if (state is SharedExpenseGroupInvitesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SharedExpenseGroupInvitesError) {
                  return Center(
                    child: Text(state.errorMessage),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          ],
        ),
      ),
    );
  }

  Card _buildGroupInviteCard(GroupInvite groupInvite) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.8), // Updated from withOpacity
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                ),
                children: [
                  const TextSpan(
                    text: 'Username',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF456EFE),
                    ),
                  ),
                  TextSpan(
                    text: ' invited you to their',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                          .withOpacity(0.8), // Updated from withOpacity
                    ),
                  ),
                  const TextSpan(
                    text: ' Group Name ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF456EFE),
                    ),
                  ),
                  TextSpan(
                    text: ' shared expense group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                          .withOpacity(0.8), // Updated to use withOpacity
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap below to accept or decline the invitation.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            if (groupInvite.isAccepted == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isAccepted = false;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins'),
                    ),
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAccepted = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF456EFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              )
            else
              Text(
                groupInvite.isAccepted!
                    ? 'You accepted the invite'
                    : 'You declined the invite',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey,
                ),
              )
          ],
        ),
      ),
    );
  }
}

class DefaultNotification extends StatelessWidget {
  const DefaultNotification({
    super.key,
    required this.notifications,
  });

  final List<Map<String, dynamic>> notifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications,
            size: 32,
            color: notifications[0]['isRead']
                ? Colors.grey
                : const Color(0xFF456EFE),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Update',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        notifications[0]['isRead'] ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your weekly budget summary is now available.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color:
                        notifications[0]['isRead'] ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2 hours ago',
                  style: TextStyle(
                    fontSize: 12,
                    color: notifications[0]['isRead']
                        ? Colors.grey
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
