import 'package:financial_app/blocs/shared_expense/shared_expense_bloc.dart';
import 'package:financial_app/enums/user_group_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InviteMemberScreen extends StatefulWidget {
  final String groupId;
  const InviteMemberScreen({super.key, required this.groupId});

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final TextEditingController _emailController = TextEditingController();
  UserGroupStatus? userStatus;
  bool isLoading = false;
  bool isInvited = false;

  late SharedExpenseBloc _sharedExpenseBloc;

  @override
  void initState() {
    _sharedExpenseBloc = context.read<SharedExpenseBloc>();
    super.initState();
  }

  void _searchUser() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
        ),
      );
      return;
    }

    _sharedExpenseBloc.add(SharedExpenseFetchUserByEmailRequest(
      email: email,
      groupId: widget.groupId,
    ));
  }

  void _sendInvite(String email) {
    _sharedExpenseBloc.add(SharedExpenseSendInviteRequest(
      email: email,
      groupId: widget.groupId,
    ));
    _sharedExpenseBloc.stream.listen((state) {
      if (state is SharedExpenseGroupInviteSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to $email'),
          ),
        );
        setState(() {
          isInvited = true;
        });
      } else if (state is SharedExpenseGroupInviteError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.errorMessage}'),
          ),
        );
        setState(() {
          isInvited = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invite Member',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocListener<SharedExpenseBloc, SharedExpenseState>(
        listener: (context, state) {
          if (state is SharedExpenseUserLoading) {
            setState(() {
              isLoading = true;
              userStatus = null;
            });
          } else if (state is SharedExpenseUserFetched) {
            setState(() {
              isLoading = false;
              userStatus = state.userGroupStatus;
            });
          } else if (state is SharedExpenseUserError) {
            setState(() {
              isLoading = false;
              userStatus = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage}'),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: ' Enter email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF456EFE),
                        )),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.search,
                        fill: 1,
                      ),
                      onPressed: _searchUser,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator()
              else if (userStatus != null)
                _buildUserStatusCard()
              else if (_emailController.text.isNotEmpty)
                const Text('Search for a user by email'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStatusCard() {
    final email = _emailController.text.trim();

    switch (userStatus) {
      case UserGroupStatus.notFound:
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('User not found with this email'),
          ),
        );
      case UserGroupStatus.available:
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.blue.shade50,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, color: Color(0xFF456EFE)),
            ),
            title: Text(
              email,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: isInvited
                ? TextButton.icon(
                    icon: const Icon(Icons.check, color: Colors.green),
                    label: const Text('Invited',
                        style: TextStyle(color: Colors.green)),
                    onPressed: null,
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF456EFE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _sendInvite(email),
                    child: const Text(
                      'Invite',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        );
      case UserGroupStatus.invited:
        return Card(
          color: Colors.amber.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.pending, color: Colors.amber.shade700),
                const SizedBox(width: 10),
                const Expanded(
                  child:
                      Text('This user has already been invited to the group'),
                ),
              ],
            ),
          ),
        );
      case UserGroupStatus.inGroup:
        return Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('This user is already a member of the group'),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
