import 'package:financial_app/components/simple_button.dart';
import 'package:flutter/material.dart';

class GroupSharingFirst extends StatefulWidget {
  static const routeName = '/group-sharing-first';

  const GroupSharingFirst({super.key});

  @override
  State<GroupSharingFirst> createState() => _GroupSharingFirstState();
}

class _GroupSharingFirstState extends State<GroupSharingFirst> {
  @override
  Widget build(BuildContext context) {
    final List<String> groups = [];

    void addGroup() {
      setState(() {
        groups.add('Group ${groups.length + 1}');
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Group Budget Sharing",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF456EFE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Add groups to share your budget with others",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildGroupButton("Kandy Trip"),
                  const SizedBox(height: 15),
                  _buildGroupButton("Apartment Bills"),
                  const SizedBox(height: 15),
                  _buildGroupButton("Birthday Party"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SimpleButton(
              data: 'Add a Group',
              onPressed: addGroup,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupButton(String title) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3,
        backgroundColor: Colors.white,
        foregroundColor:const Color(0xFF456EFE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
      ),
      onPressed: () {},
      child: Text(title),
    );
  }
}
//! Groups nattan, Add A Group kiyala pennala, button ekak click karama group ekak add karanna hdnawa

//! nattan group list eka pennanawa.
// body: groups.isEmpty
//           ? const Center(
//               child: Text(
//                 'Add a Group',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             )
//           : ListView.builder(
//               itemCount: groups.length,
//               itemBuilder: (context, index) {
//                 return ListTile(title: Text(groups[index]));
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           addGroup;
//         },
//         child: const Icon(Icons.add),
//
