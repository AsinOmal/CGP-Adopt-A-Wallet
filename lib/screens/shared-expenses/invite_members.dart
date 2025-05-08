import 'package:flutter/material.dart';

class InviteMemberScreen extends StatefulWidget {
  const InviteMemberScreen({super.key});

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? foundUserEmail;
  bool isLoading = false;

  void _searchUser() async {
    setState(() {
      isLoading = true;
      foundUserEmail = null;
    });

    //! Mock SEARCH HTODFKSDNSKDNSKDNDSDSDSD
    await Future.delayed(const Duration(seconds: 1));
    final input = _emailController.text.trim().toLowerCase();

    if (input == 'asin@example.com' ||
        input == 'sarah@example.com' ||
        input == 'jason@example.com') {
      setState(() {
        foundUserEmail = input;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _sendInvite(String email) {
    // TODO: Add invite sending logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite sent to $email')),
    );
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
      body: Padding(
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
            else if (foundUserEmail != null)
              Card(
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
                    foundUserEmail!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF456EFE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _sendInvite(foundUserEmail!),
                    child: const Text(
                      'Invite',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            else if (_emailController.text.isNotEmpty)
              const Text('No user found'),
          ],
        ),
      ),
    );
  }
}
