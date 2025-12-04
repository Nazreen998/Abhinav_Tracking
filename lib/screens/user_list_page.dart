import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'add_user_page.dart';
import 'edit_user_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final UserService userService = UserService();
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => loading = true);

    allUsers = await userService.getUsers();
    filteredUsers = allUsers;

    setState(() => loading = false);
  }

  void searchFilter(String text) {
    text = text.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((u) {
        return u.name.toLowerCase().contains(text) ||
            u.mobile.toLowerCase().contains(text) ||
            u.role.toLowerCase().contains(text) ||
            u.segment.toLowerCase().contains(text);
      }).toList();
    });
  }

  Future<void> deleteUser(UserModel u) async {
    final confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Delete"),
        content: Text("Delete user '${u.name}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await userService.deleteUser(u.id.toString());

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User deleted")));
      loadUsers();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Delete failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.currentUser?["role"] != "master") {
      return const Scaffold(
        body: Center(
          child: Text(
            "Access Denied",
            style: TextStyle(fontSize: 22, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007BFF),
              Color(0xFF66B2FF),
              Color(0xFFB8E0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // 🔙 BACK BUTTON + TITLE
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "User List",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: searchFilter,
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (_, i) {
                          final u = filteredUsers[i];
                          return _userCard(u);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // ADD USER BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0066CC),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserPage()),
          ).then((_) => loadUsers());
        },
      ),
    );
  }

  // ⭐ USER CARD
  Widget _userCard(UserModel u) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),

      child: ListTile(
        title: Text(
          u.name,
          style: const TextStyle(
              color: Color(0xFF003366),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Mobile: ${u.mobile}\nRole: ${u.role}\nSegment: ${u.segment}",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: PopupMenuButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: const Icon(Icons.more_vert, color: Color(0xFF003366)),
          onSelected: (v) {
            if (v == "edit") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditUserPage(user: u)),
              ).then((_) => loadUsers());
            }
            if (v == "delete") deleteUser(u);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
                value: "edit", child: Text("Edit", style: TextStyle(color: Colors.blue))),
            PopupMenuItem(
                value: "delete", child: Text("Delete", style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
