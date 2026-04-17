import 'package:bluemoonapp/constants/api_constants.dart';
import 'package:bluemoonapp/services/api_service.dart';
import 'package:flutter/material.dart';

class EditBillScreen extends StatefulWidget {
  final Map bill;

  const EditBillScreen({super.key, required this.bill});

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final ApiService _api = ApiService();

  late TextEditingController apartmentController;
  late TextEditingController amountController;
  late TextEditingController descController;

  late String billType;
  DateTime? dueDate;

  bool loading = false;

  final List<String> types = [
    "ELECTRICITY",
    "WATER",
    "SERVICE_COST",
    "FIXED_COST",
    "CONTRIBUTION",
    "OTHER"
  ];

  // ===== UI STYLE =====
  InputDecoration _input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    apartmentController =
        TextEditingController(text: widget.bill['apartmentNumber'] ?? '');

    amountController =
        TextEditingController(text: widget.bill['amount'].toString());

    descController =
        TextEditingController(text: widget.bill['description'] ?? '');

    billType = types.contains(widget.bill['billType'])
        ? widget.bill['billType']
        : "OTHER";

    if (widget.bill['dueDate'] != null) {
      dueDate = DateTime.tryParse(widget.bill['dueDate']);
    }
  }

  // ===== DATE PICKER =====
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => dueDate = picked);
    }
  }

  // ===== UPDATE =====
  Future<void> update() async {
    final amount = double.tryParse(amountController.text);

    if (apartmentController.text.isEmpty ||
        amount == null ||
        descController.text.isEmpty ||
        dueDate == null) {
      _show("Fill all fields correctly");
      return;
    }

    setState(() => loading = true);

    final res = await _api.put(
      "${ApiConstants.editBill}/${widget.bill['id']}",
      body: {
        "apartmentNumber": apartmentController.text,
        "billType": billType,
        "description": descController.text,
        "amount": amount,
        "dueDate": dueDate!.toIso8601String().split("T")[0],
      },
    );

    setState(() => loading = false);

    if (res.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      _show("Update failed: ${res.statusCode}");
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Bill")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Apartment
            TextField(
              controller: apartmentController,
              decoration: _input("Apartment Number", Icons.home),
            ),

            const SizedBox(height: 14),

            // Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: _input("Amount", Icons.attach_money),
            ),

            const SizedBox(height: 14),

            // Description
            TextField(
              controller: descController,
              decoration: _input("Description", Icons.description),
            ),

            const SizedBox(height: 14),

            // Bill Type
            DropdownButtonFormField(
              value: billType,
              items: types
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.replaceAll("_", " ")),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => billType = v.toString()),
              decoration: _input("Bill Type", Icons.category),
            ),

            const SizedBox(height: 14),

            // Date
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: _input("Due Date", Icons.calendar_today),
                child: Text(
                  dueDate == null
                      ? "Select date"
                      : dueDate!.toLocal().toString().split(" ")[0],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Button
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
                    : const Text("Update", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}