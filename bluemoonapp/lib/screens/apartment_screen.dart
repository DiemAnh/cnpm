import 'dart:convert';
import 'package:bluemoonapp/screens/apartment_screen_action/add_apartment_screen.dart';
import 'package:bluemoonapp/screens/apartment_screen_action/edit_apartment_screen.dart';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../services/api_service.dart';

class ApartmentScreen extends StatefulWidget {
  static const routeName = '/apartment';

  const ApartmentScreen({super.key});

  @override
  State<ApartmentScreen> createState() => _ApartmentScreenState();
}

class _ApartmentScreenState extends State<ApartmentScreen> {
  final ApiService _apiService = ApiService();

  bool _loading = false;
  String? _error;
  List<dynamic> _apartments = [];

  int _currentPage = 0;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }

  // ================= LOAD =================
  Future<void> _loadApartments() async {
    setState(() {
      _loading = true;
      _error = null;
      _currentPage = 0;
    });

    try {
      final response = await _apiService.get(
        ApiConstants.apartments,
        auth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _apartments = data as List<dynamic>;
        });
      } else {
        _error = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    }

    setState(() {
      _loading = false;
    });
  }

  // ================= DELETE =================
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this apartment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteApartment(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteApartment(int id) async {
    setState(() => _loading = true);

    try {
      final res = await _apiService.delete(
        "${ApiConstants.deleteApartment}/$id",
      );

      print("DELETE STATUS: ${res.statusCode}");

      if (res.statusCode == 204) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Deleted successfully")));

        _loadApartments(); // reload list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: ${res.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _loading = false);
  }

  // ================= PAGINATION =================
  List<dynamic> get _pagedApartments {
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;

    return _apartments.sublist(
      start,
      end > _apartments.length ? _apartments.length : end,
    );
  }

  void _nextPage() {
    if ((_currentPage + 1) * _pageSize < _apartments.length) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  // ================= UI =================
  Color _statusColor(String status) {
    switch (status) {
      case 'OCCUPIED':
        return Colors.red;
      case 'VACANT':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDetail(dynamic item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apartment Detail'),
        content: Text(const JsonEncoder.withIndent('  ').convert(item)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editApartment(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditApartmentScreen(apartment: item)),
    );

    if (result == true) {
      _loadApartments();
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartment Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApartments,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            : _apartments.isEmpty
            ? const Center(child: Text('No apartments'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pagedApartments.length,
                      itemBuilder: (context, index) {
                        final item = _pagedApartments[index];

                        return Card(
                          elevation: 6,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // HEADER
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['apartmentNumber'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),

                                    // STATUS CHIP
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(
                                          item['status'],
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item['status'] ?? '',
                                        style: TextStyle(
                                          color: _statusColor(item['status']),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // INFO GRID
                                Row(
                                  children: [
                                    Expanded(
                                      child: _infoItem(
                                        "Room",
                                        item['roomNumber'],
                                      ),
                                    ),
                                    Expanded(
                                      child: _infoItem("Floor", item['floor']),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _infoItem(
                                        "Area",
                                        "${item['area']} m²",
                                      ),
                                    ),
                                    Expanded(
                                      child: _infoItem("Type", item['type']),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                const Divider(),

                                // ACTIONS
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Apartment ID: ${item["id"].toString()}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _actionBtn(
                                          icon: Icons.visibility,
                                          onTap: () => _showDetail(item),
                                        ),
                                        _actionBtn(
                                          icon: Icons.edit_outlined,
                                          onTap: () => _editApartment(item),
                                        ),
                                        _actionBtn(
                                          icon: Icons.delete_outlined,
                                          color: Colors.red,
                                          onTap: () =>
                                              _confirmDelete(item['id']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // PAGINATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${_currentPage + 1} / ${(_apartments.length / _pageSize).ceil()}',
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _prevPage,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          IconButton(
                            onPressed: _nextPage,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: _goToAddScreen,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _infoItem(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value?.toString() ?? '',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.grey[700]),
      onPressed: onTap,
      splashRadius: 22,
    );
  }

  void _goToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddApartmentScreen()),
    );

    if (result == true) {
      _loadApartments();
    }
  }
}
