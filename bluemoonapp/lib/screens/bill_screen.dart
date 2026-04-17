import 'dart:convert';
import 'package:bluemoonapp/screens/bill_screen_action/add_bill_screen.dart';
import 'package:bluemoonapp/screens/bill_screen_action/edit_bill_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final ApiService _api = ApiService();

  List bills = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadBills();
  }

  Future<void> loadBills() async {
    setState(() => loading = true);

    final res = await _api.get(ApiConstants.bills, auth: true);

    if (res.statusCode == 200) {
      setState(() {
        bills = jsonDecode(res.body);
      });
    }

    setState(() => loading = false);
  }

  Future<void> deleteBill(int id) async {
    final res = await _api.delete("${ApiConstants.deleteBill}/$id");
    if (res.statusCode == 204) loadBills();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete bill?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteBill(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void goAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBillScreen()),
    );
    if (result == true) loadBills();
  }

  void goEdit(Map item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditBillScreen(bill: item)),
    );
    if (result == true) loadBills();
  }

  Color billColor(String type) {
    switch (type) {
      case "ELECTRICITY":
        return Colors.orange;
      case "WATER":
        return Colors.blue;
      case "SERVICE_COST":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  bool isOverdue(String? dueDate) {
    if (dueDate == null) return false;
    return DateTime.parse(dueDate).isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bills"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadBills),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goAdd,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bills.length,
              itemBuilder: (_, i) {
                final item = bills[i];
                final overdue = isOverdue(item['dueDate']);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['apartmentNumber'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: billColor(item['billType'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item['billType'] ?? '',
                                  style: TextStyle(
                                    color: billColor(item['billType']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${item['amount']} VND",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['description'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16,
                                  color: overdue
                                      ? Colors.red
                                      : Colors.blueGrey),
                              const SizedBox(width: 4),
                                      Text(
                                "Due: ${item['dueDate'] ?? 'N/A'}",
                                style: TextStyle(
                                  color: overdue
                                      ? Colors.red
                                      : Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => goEdit(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        confirmDelete(item['id']),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}