import 'package:financial_app/screens/shared-expenses/create_a_group.dart';
import 'package:financial_app/screens/shared-expenses/group_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SharedExpensePage extends StatefulWidget {
  static const routeName = '/group-sharing-first';

  const SharedExpensePage({super.key});

  @override
  State<SharedExpensePage> createState() => _SharedExpensePageState();
}

class _SharedExpensePageState extends State<SharedExpensePage> {
  final List<String> groups = ['Apartment 5B', 'Trip to Kandy', 'Project Team'];

  void addGroup() {
    setState(() {
      groups.add('Group ${groups.length + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Shared Expenses",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage your shared expenses with friends and family",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildGroupCard(groups[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(String title, int index) {
    return Slidable(
      key: ValueKey(title),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              setState(() {
                groups.removeAt(index);
              });
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 185, 184, 184).withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailsScreen(),
              ),
            );
          }, // Add navigation or functionality here
        ),
      ),
    );
  }
}
