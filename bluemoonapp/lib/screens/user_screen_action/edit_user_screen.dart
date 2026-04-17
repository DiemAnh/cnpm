import 'package:flutter/material.dart';
import 'package:bluemoonapp/constants/api_constants.dart';
import 'package:bluemoonapp/services/api_service.dart';

class EditUserScreen extends StatefulWidget {
  final Map user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final ApiService _api = ApiService();

  late TextEditingController fullNameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;
  late TextEditingController apartmentController;

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

  @override
  void initState() {
    super.initState();

    fullNameController =
        TextEditingController(text: widget.user['fullName'] ?? '');

    ageController =
        TextEditingController(text: widget.user['age']?.toString() ?? '');

    phoneController =
        TextEditingController(text: widget.user['phone'] ?? '');

    apartmentController =
        TextEditingController(
          text: widget.user['apartmentNumbers'] != null
              ? widget.user['apartmentNumbers'].join(",")
              : '',
        );

    role = widget.user['role'] ?? "USER";
    status = widget.user['status'] ?? "TAMTRU";
  }

  Future<void> update() async {
    setState(() => loading = true);

    final res = await _api.post(
      "${ApiConstants.editUser}/${widget.user['id']}",
      body: {
        "fullName": fullNameController.text,
        "age": int.tryParse(ageController.text),
        "phone": phoneController.text,
        "role": role,
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
    fullNameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    apartmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: fullNameController, decoration: input("Full Name", Icons.badge)),
            const SizedBox(height: 12),
            TextField(controller: ageController, keyboardType: TextInputType.number, decoration: input("Age", Icons.numbers)),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: input("Phone", Icons.phone)),
            const SizedBox(height: 12),
            TextField(controller: apartmentController, decoration: input("Apartment", Icons.home)),
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
                onPressed: loading ? null : update,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update"),
              ),
            )
          ],
        ),
      ),
    );
  }
}