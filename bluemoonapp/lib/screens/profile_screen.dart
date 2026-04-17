import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bluemoonapp/services/api_service.dart';
import 'package:bluemoonapp/services/secure_storage_service.dart';
import 'package:bluemoonapp/constants/api_constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  final SecureStorageService _storage = SecureStorageService();

  Map<String, dynamic>? user;
  Map<String, dynamic>? resident;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);

    try {
      final res = await _api.get(ApiConstants.profile, auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          user = data;
          resident = data['resident'] ?? {};
        });
      }
    } catch (e) {
      debugPrint("Profile error: $e");
    }

    setState(() => loading = false);
  }

  Future<void> logout() async {
    await _storage.deleteToken();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (_) => false,
    );
  }

  Widget item(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              (value.isEmpty) ? "-" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = user ?? {};
    final r = resident ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.indigo],
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          u['username'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          u['role'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // USER INFO
                  item("Username", u['username'] ?? '', Icons.person),
                  item("Full Name", r['fullName'] ?? '', Icons.badge),
                  item("Email", r['email'] ?? '', Icons.email),
                  item("Phone", r['phone'] ?? '', Icons.phone),
                  item("Age", "${r['age'] ?? ''}", Icons.cake),
                  item("Status", r['status'] ?? '', Icons.info),
                ],
              ),
            ),
    );
  }
}