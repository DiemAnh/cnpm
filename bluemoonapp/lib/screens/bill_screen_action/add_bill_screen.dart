import 'package:flutter/material.dart';
import 'package:bluemoonapp/constants/api_constants.dart';
import 'package:bluemoonapp/services/api_service.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final apartmentController = TextEditingController();
  final amountController = TextEditingController();
  final descController = TextEditingController();

  String billType = "ELECTRICITY";
  DateTime? dueDate;

  bool _loading = false;

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

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => dueDate = picked);
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate() || dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _loading = true);

    final amount = double.tryParse(amountController.text);

    try {
      final res = await _api.post(
        ApiConstants.addBill,
        body: {
          "apartmentNumber": apartmentController.text,
          "billType": billType,
          "description": descController.text,
          "amount": amount,
          "dueDate": dueDate!.toIso8601String().split("T")[0],
        },
      );

      if (res.statusCode == 200) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Bill")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: apartmentController,
                  decoration:
                      _input("Apartment Number", Icons.home),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Required" : null,
                ),
      
                const SizedBox(height: 14),
      
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: _input("Amount", Icons.attach_money),
                  validator: (v) {
                    final val = double.tryParse(v ?? "");
                    if (val == null || val <= 0) {
                      return "Invalid amount";
                    }
                    return null;
                  },
                ),
      
                const SizedBox(height: 14),
      
                TextFormField(
                  controller: descController,
                  decoration:
                      _input("Description", Icons.description),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Required" : null,
                ),
      
                const SizedBox(height: 14),
      
                DropdownButtonFormField(
                  value: billType,
                  items: const [
                    DropdownMenuItem(
                        value: "ELECTRICITY",
                        child: Text("Electricity")),
                    DropdownMenuItem(
                        value: "WATER", child: Text("Water")),
                    DropdownMenuItem(
                        value: "SERVICE_COST",
                        child: Text("Service Cost")),
                    DropdownMenuItem(
                        value: "FIXED_COST",
                        child: Text("Fixed Cost")),
                    DropdownMenuItem(
                        value: "CONTRIBUTION",
                        child: Text("Contribution")),
                    DropdownMenuItem(
                        value: "OTHER", child: Text("Other")),
                  ],
                  onChanged: (v) =>
                      setState(() => billType = v.toString()),
                  decoration: _input("Bill Type", Icons.category),
                ),
      
                const SizedBox(height: 14),
      
                InkWell(
                  onTap: pickDate,
                  child: InputDecorator(
                    decoration:
                        _input("Due Date", Icons.calendar_today),
                    child: Text(
                      dueDate == null
                          ? "Select date"
                          : "${dueDate!.toLocal()}".split(" ")[0],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
      
                const SizedBox(height: 20),
      
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text(
                            "Save",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}