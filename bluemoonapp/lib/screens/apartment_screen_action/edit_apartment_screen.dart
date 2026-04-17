import 'package:flutter/material.dart';
import 'package:bluemoonapp/constants/api_constants.dart';
import 'package:bluemoonapp/services/api_service.dart';

class EditApartmentScreen extends StatefulWidget {
  final Map<String, dynamic> apartment;

  const EditApartmentScreen({super.key, required this.apartment});

  @override
  State<EditApartmentScreen> createState() => _EditApartmentScreenState();
}

class _EditApartmentScreenState extends State<EditApartmentScreen> {
  final ApiService _apiService = ApiService();

  late TextEditingController roomController;
  late TextEditingController areaController;
  late TextEditingController floorController;

  late String status;
  late String type;

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

  @override
  void initState() {
    super.initState();

    roomController = TextEditingController(
      text: widget.apartment['roomNumber']?.toString() ?? '',
    );

    areaController = TextEditingController(
      text: widget.apartment['area']?.toString() ?? '',
    );

    floorController = TextEditingController(
      text: widget.apartment['floor']?.toString() ?? '',
    );

    status = (widget.apartment['status'] ?? 'VACANT').toString();
    type = (widget.apartment['type'] ?? 'STANDARD').toString();
  }

  Future<void> _updateApartment() async {
    setState(() => _loading = true);

    final body = {
      "id": widget.apartment["id"],
      "apartmentNumber": widget.apartment["apartmentNumber"],
      "roomNumber": roomController.text,
      "area": double.tryParse(areaController.text) ?? 0,
      "floor": int.tryParse(floorController.text) ?? 0,
      "status": status,
      "type": type,
    };

    try {
      final res = await _apiService.post(
        ApiConstants.adminEditApartment,
        body: body,
      );

      if (res.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showError("Update failed: ${res.statusCode}");
      }
    } catch (e) {
      _showError("Error: $e");
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Apartment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: roomController,
              decoration: _input("Room Number", Icons.meeting_room),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: areaController,
              keyboardType: TextInputType.number,
              decoration: _input("Area (m²)", Icons.square_foot),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: floorController,
              keyboardType: TextInputType.number,
              decoration: _input("Floor", Icons.layers),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(value: "VACANT", child: Text("VACANT")),
                DropdownMenuItem(value: "OCCUPIED", child: Text("OCCUPIED")),
              ],
              onChanged: (v) => setState(() => status = v.toString()),
              decoration: _input("Status", Icons.info),
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField(
              value: type,
              items: const [
                DropdownMenuItem(value: "STANDARD", child: Text("STANDARD")),
                DropdownMenuItem(value: "KIOT", child: Text("KIOT")),
                DropdownMenuItem(value: "PENHOUSE", child: Text("PENHOUSE")),
              ],
              onChanged: (v) => setState(() => type = v.toString()),
              decoration: _input("Type", Icons.apartment),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _updateApartment,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}