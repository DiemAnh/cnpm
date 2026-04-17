import 'package:flutter/material.dart';
import 'package:bluemoonapp/constants/api_constants.dart';
import 'package:bluemoonapp/services/api_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final ApiService _api = ApiService();

  final nameController = TextEditingController();
  final passController = TextEditingController();
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final apartmentController = TextEditingController();

  String role = "USER";
  String status = "TAMTRU";

  bool loading = false;

  InputDecoration input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> save() async {
    setState(() => loading = true);

    final res = await _api.post(
      ApiConstants.addUser,
      body: {
        "name": nameController.text,
        "password": passController.text,
        "role": role,
        "fullName": fullNameController.text,
        "age": int.tryParse(ageController.text),
        "phone": phoneController.text,
        "email": emailController.text,
        "apartmentNumbers": [apartmentController.text],
        "status": status
      },
    );

    setState(() => loading = false);

    if (res.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.body)));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passController.dispose();
    fullNameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    apartmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: input("Username", Icons.person)),
            const SizedBox(height: 12),
            TextField(controller: passController, obscureText: true, decoration: input("Password", Icons.lock)),
            const SizedBox(height: 12),
            TextField(controller: fullNameController, decoration: input("Full Name", Icons.badge)),
            const SizedBox(height: 12),
            TextField(controller: ageController, keyboardType: TextInputType.number, decoration: input("Age", Icons.numbers)),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: input("Phone", Icons.phone)),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: input("Email", Icons.email)),
            const SizedBox(height: 12),
            TextField(controller: apartmentController, decoration: input("Apartment Number", Icons.home)),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: role,
              items: const [
                DropdownMenuItem(value: "USER", child: Text("USER")),
                DropdownMenuItem(value: "ADMIN", child: Text("ADMIN")),
              ],
              onChanged: (v) => setState(() => role = v.toString()),
              decoration: input("Role", Icons.security),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(value: "TAMTRU", child: Text("Tạm trú")),
                DropdownMenuItem(value: "THUONGTRU", child: Text("Thường trú")),
                DropdownMenuItem(value: "TAMVANG", child: Text("Tạm vắng")),
              ],
              onChanged: (v) => setState(() => status = v.toString()),
              decoration: input("Status", Icons.person_outline),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : save,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create"),
              ),
            )
          ],
        ),
      ),
    );
  }
}