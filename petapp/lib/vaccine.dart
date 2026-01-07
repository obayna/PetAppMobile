import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class VaccineScreen extends StatefulWidget {
  final String petName;
  final String petType;

  const VaccineScreen({super.key, required this.petName, required this.petType});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> vaccines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVaccines();
  }

  List<Map<String, dynamic>> getDefaultVaccines() {
    final lowerType = widget.petType.toLowerCase();
    if (lowerType.contains("dog")) {
      return [
        {"name": "Rabies", "isTaken": false, "type": "Core"},
        {"name": "Distemper", "isTaken": false, "type": "Core"},
        {"name": "Parvovirus", "isTaken": false, "type": "Core"},
        {"name": "Bordetella", "isTaken": false, "type": "Non-Core"},
      ];
    } else if (lowerType.contains("cat")) {
      return [
        {"name": "Rabies", "isTaken": false, "type": "Core"},
        {"name": "Feline Distemper", "isTaken": false, "type": "Core"},
        {"name": "FeLV", "isTaken": false, "type": "Non-Core"},
      ];
    } else {
      return [
        {"name": "Annual Checkup", "isTaken": false, "type": "General"},
        {"name": "Parasite Control", "isTaken": false, "type": "General"},
      ];
    }
  }

  Future<void> loadVaccines() async {
    String key = "vaccines_real_${widget.petName}";
    String? savedData = await storage.read(key: key);

    setState(() {
      if (savedData != null) {
        vaccines = List<Map<String, dynamic>>.from(json.decode(savedData));
      } else {
        vaccines = getDefaultVaccines();
      }
      isLoading = false;
    });
  }

  Future<void> saveVaccines() async {
    String key = "vaccines_real_${widget.petName}";
    await storage.write(key: key, value: json.encode(vaccines));
  }

  Widget vaccineTile(Map<String, dynamic> v, int index) {
    bool isTaken = v['isTaken'];
    String type = v['type'] ?? "General";

    return Card(
      color: isTaken ? Colors.green[50] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        value: isTaken,
        onChanged: (val) {
          setState(() => vaccines[index]['isTaken'] = val!);
          saveVaccines();
        },
        title: Text(
          v['name'],
          style: TextStyle(
            decoration: isTaken ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text("$type - ${isTaken ? "Completed" : "Not Taken"}"),
        secondary: Icon(
          isTaken ? Icons.check : Icons.vaccines,
          color: isTaken ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("${widget.petName}'s Medical"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      child: Icon(
                        Icons.health_and_safety,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vaccination Record",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          widget.petName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: vaccines.length,
                  itemBuilder: (context, index) =>
                      vaccineTile(vaccines[index], index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}